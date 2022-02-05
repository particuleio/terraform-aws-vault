locals {

  asg = merge(
    var.asg_defaults,
    var.asg
  )

  asg_secondary = merge(
    var.asg_defaults,
    var.asg_secondary
  )

  nlbs = { for k, v in var.nlbs : k => merge(
    var.nlb_defaults,
    v)
  }

  nlbs_secondary = { for k, v in var.nlbs_secondary : k => merge(
    var.nlb_defaults,
    v)
  }
}
