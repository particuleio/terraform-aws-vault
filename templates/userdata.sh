#! /usr/bin/env bash

# The MIT License (MIT)
# Copyright (c) 2014-2021 Avant, Sean Lingren

# Get the Instance ID
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

# Set the Hostname
hostnamectl set-hostname "${ name_prefix }-$INSTANCE_ID"
systemctl restart rsyslog.service

# Configure SSM Agent
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

cat <<EOF > ${ vault_config_dir }/config.hcl
cluster_name      = "${ name_prefix }"
max_lease_ttl     = "192h" # One week
default_lease_ttl = "192h" # One week
ui                = "true"

api_addr      = "${ vault_dns_address }"
cluster_addr  = "https://MY_IP_SET_IN_USERDATA:8201"

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
  tls_cert_file      = "${ vault_cert_dir }/cert.crt"
  tls_key_file       = "${ vault_cert_dir }/cert.key"
}


storage "dynamodb" {
  ha_enabled = "true"
  region     = "${ region }"
  table      = "${ dynamodb_table_name }"
}

${ vault_additional_config }
EOF

# Get SSL Certs
aws --region ${ region } secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${region}:${account_id}:secret:${name_prefix}/tls/ca_pem --query SecretString --output text > ${ vault_cert_dir }/ca.crt

aws --region ${ region } secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${region}:${account_id}:secret:${name_prefix}/tls/ca_pem --query SecretString --output text > ${ vault_cert_dir }/cert.crt

aws --region ${ region } secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${region}:${account_id}:secret:${name_prefix}/tls/cert_pem --query SecretString --output text >> ${ vault_cert_dir }/cert.crt

aws --region ${ region } secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:${region}:${account_id}:secret:${name_prefix}/tls/cert_pem --query SecretString --output text >> ${ vault_cert_dir }/cert.key

# Ensure correct permissions
chown -R vault:vault ${ vault_config_dir }
chown -R vault:vault ${ vault_cert_dir } && chmod 600 ${ vault_cert_dir }/*

# Get My IP Address
MYIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# Add My IP Address as cluster_address in Vault Configuration
sed -i -e "s/MY_IP_SET_IN_USERDATA/$MYIP/g" ${ vault_config_dir }/config.hcl

${ vault_additional_userdata }

# Start Vault now and on boot
systemctl enable vault
systemctl start vault
