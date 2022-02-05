output "nlbs" {
  value = aws_lb.vault
}

output "sg" {
  value = module.sg
}

output "asg" {
  value = module.asg
}
