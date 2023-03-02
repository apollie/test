output "vpc" {
  value = aws_vpc.my_vpc[0].id
}

output "subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

output "sg_ssh_pub" {
  value = aws_security_group.allow_ssh_pub.id
}

output "sg_icmp_pub" {
  value = aws_security_group.allow_icmp_pub.id
}