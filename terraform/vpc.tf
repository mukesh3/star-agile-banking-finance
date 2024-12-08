resource "aws_vpc" "sa-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "capstone-mukku"
  }
}

resource "aws_subnet" "subnet-1" {
  depends_on = [aws_vpc.sa-vpc]
  vpc_id     = aws_vpc.sa-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_route_table" "sa-route-table" {
  vpc_id = aws_vpc.sa-vpc.id

tags = {
    Name = "sa-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.sa-route-table.id
}

resource "aws_internet_gateway" "gw" {
  depends_on = [aws_vpc.sa-vpc]
  vpc_id = aws_vpc.sa-vpc.id

  tags = {
    Name = "gw"



  }
}

resource "aws_route" "sa-route" {
  route_table_id            = aws_route_table.sa-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

variable "sg_ports" {
type = list(number)
default = [80,8080,22,443]
}


resource "aws_security_group" "sa-sg" {
  name        = "sa-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.sa-vpc.id
  dynamic ingress {
   for_each = var.sg_ports
   iterator = port
   content {
   from_port        = port.value
    to_port          = port.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
   egress {
   from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}

output "vpc-id" {
  value = aws_vpc.sa-vpc.id
}