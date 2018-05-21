# Common OUTPUTS

output "Ec2-Priv-PrivIp" {
  value = "${aws_instance.Dev_jump_Box.private_ip}"
}
