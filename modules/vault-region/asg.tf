module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 5.0"

  name = try(var.asg.name_prefix, var.name_prefix)

  key_name = try(var.asg.key_name, null)

  min_size            = try(var.asg.min_size, 0)
  max_size            = try(var.asg.max_size, 3)
  desired_capacity    = try(var.asg.desired_capacity, 3)
  vpc_zone_identifier = var.asg.vpc_zone_identifier

  target_group_arns = [for k, v in var.nlbs : aws_lb_target_group.vault[k].arn]

  health_check_grace_period = try(var.asg.health_check_grace_period, 0)
  wait_for_capacity_timeout = try(var.asg.wait_for_capacity_timeout, 0)
  termination_policies      = try(var.asg.termination_policies, ["OldestInstance"])

  use_lt                 = true
  create_lt              = true
  lt_name                = try(var.asg.name_prefix, var.name_prefix)
  update_default_version = true

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 66
    }
    triggers = ["tag"]
  }

  user_data_base64 = base64encode(data.template_file.userdata.rendered)

  iam_instance_profile_arn = try(var.asg.iam_instance_profile_arn, var.iam_instance_profile_arn)

  image_id          = try(var.asg.ami_id, data.aws_ami.vault.id)
  instance_type     = try(var.asg.instance_type, "t3a.micro")
  ebs_optimized     = true
  enable_monitoring = true

  network_interfaces = [
    {
      security_groups             = [module.sg.security_group_id]
      associate_public_ip_address = try(var.asg.associate_public_ip_address, false)
    }
  ]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = try(var.asg.disk_size, 20)
        volume_type           = try(var.asg.disk_type, "gp3")
      }
    }
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = [try(var.asg.tags, {})]

  tags_as_map = try(var.asg.tags_as_map, {})
}
