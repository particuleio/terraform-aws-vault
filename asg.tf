module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = var.name_prefix

  key_name = var.asg_key_name

  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.asg_vpc_zone_identifier

  use_lt                 = true
  create_lt              = true
  lt_name                = var.name_prefix
  update_default_version = true

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 66
    }
    triggers = ["tag"]
  }

  user_data_base64 = base64encode(data.template_file.userdata.rendered)

  iam_instance_profile_arn = aws_iam_instance_profile.vault.arn

  image_id          = var.asg_ami_id
  instance_type     = var.asg_instance_type
  ebs_optimized     = true
  enable_monitoring = true

  network_interfaces = [
    {
      security_groups             = [module.sg_vault.security_group_id]
      associate_public_ip_address = true
    }
  ]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.asg_disk_size
        volume_type           = "gp3"
      }
    }
  ]

  tags = var.asg_tags

  tags_as_map = merge(
    var.tags,
    var.asg_tags_as_map
  )
}
