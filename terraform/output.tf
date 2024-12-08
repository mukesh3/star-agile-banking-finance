output "vpc-id" {
  value = aws_vpc.sa-vpc.id
}

output "instance-id" {
  value = aws_instance.myec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.myec2.public_ip
}