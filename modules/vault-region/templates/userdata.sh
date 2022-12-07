#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

systemctl start amazon-ssm-agent.service
systemctl enable amazon-ssm-agent.service

# Set Bin directory
BIN_DIR=/usr/local/bin

# Get the Instance ID
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

# Set the Hostname
hostnamectl set-hostname "${ name_prefix }-$INSTANCE_ID"

# Download cfssl
curl -sL https://github.com/cloudflare/cfssl/releases/download/v${ cfssl_version }/cfssl_${ cfssl_version }_linux_amd64 -o $BIN_DIR/cfssl
curl -sL https://github.com/cloudflare/cfssl/releases/download/v${ cfssl_version }/cfssljson_${ cfssl_version }_linux_amd64 -o $BIN_DIR/cfssljson
chmod +x $BIN_DIR/cfssl
chmod +x $BIN_DIR/cfssljson

# Get Metadata
MYIP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
MYDNS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-hostname)

cat <<EOF > ${ vault_config_dir }/config.hcl
cluster_name      = "${ name_prefix }"
max_lease_ttl     = "${ vault_max_lease_ttl }"
default_lease_ttl = "${ vault_default_lease_ttl }"
ui                = "true"

api_addr      = "${ vault_api_address }"
cluster_addr  = "https://$MYIP:8201"

seal "awskms" {
  region     = "${ region }"
  kms_key_id = "${ vault_kms_seal_key_id }"
}

listener "tcp" {
  address     = ":9200"
  tls_disable = "true"
}

listener "tcp" {
  address         = "[::]:8200"
  cluster_address = "[::]:8201"

  tls_disable     = "false"
  tls_min_version = "tls12"
  tls_client_ca_file = "${ vault_cert_dir }/ca.crt"
  tls_cert_file      = "${ vault_cert_dir }/cert.pem"
  tls_require_and_verify_client_cert = ${ vault_tls_require_and_verify_client_cert }
  tls_key_file       = "${ vault_cert_dir }/cert-key.pem"
}


storage "dynamodb" {
  ha_enabled = "true"
  region     = "${ region }"
  table      = "${ dynamodb_table_name }"
}

${ vault_additional_config }
EOF

cat <<EOF > ${ vault_cert_dir }/cfssl-config.json
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "default": {
        "usages": [
            "signing",
            "digital signature",
            "key encipherment",
            "client auth",
            "server auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat <<EOF > ${ vault_cert_dir }/cert.json
{
  "CN": "${ vault_dns_domain }",
  "key": {
    "algo": "ecdsa",
    "size": 384
  },
  "hosts": [
    "${ vault_dns_domain }",
    "localhost",
    "127.0.0.1",
    "$MYDNS",
    "$MYIP"
  ]
}
EOF

# Get CA and generate cert
aws --region ${ region } secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${region}:${account_id}:secret:${name_prefix}/tls/ca_pem --query SecretString --output text > ${ vault_cert_dir }/ca.crt

aws --region ${ region } secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${region}:${account_id}:secret:${name_prefix}/tls/ca_key --query SecretString --output text > ${ vault_cert_dir }/ca.key

cd ${ vault_cert_dir }
$BIN_DIR/cfssl gencert -ca ca.crt -ca-key ca.key -config cfssl-config.json -profile=default cert.json | $BIN_DIR/cfssljson -bare cert

cat ${ vault_cert_dir }/ca.crt >> ${ vault_cert_dir }/cert.pem

# Ensure correct permissions
chown -R vault:vault ${ vault_config_dir }
chown -R vault:vault ${ vault_cert_dir } && chmod 600 ${ vault_cert_dir }/*

# Remove CA Key from node
rm -f ${ vault_cert_dir }/ca.key

${ vault_additional_userdata }

# Start Vault now and on boot
systemctl enable vault
systemctl start vault
