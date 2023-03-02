resource "aws_vpc" "my_vpc" {
  count                = 1
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.my_vpc[0].id
  cidr_block              = var.private_cidr_block[count.index]
  availability_zone       = var.az_list[count.index]

  tags = {
    Name = "${var.prefix}-private_subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.my_vpc[0].id
  cidr_block              = var.public_cidr_block[count.index]
  availability_zone       = var.az_list[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public_subnet"
  }
}

resource "aws_internet_gateway" "int-gw" {
  vpc_id = aws_vpc.my_vpc[0].id
  
  tags = {
        Name = "${var.prefix}-env-gw"
    }
}

resource "aws_route_table" "route-table-int" {
  vpc_id = aws_vpc.my_vpc[0].id
  
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.int-gw.id
  }
  tags = {
        Name = "${var.prefix}-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  count =  length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route-table-int.id
}




resource "aws_security_group" "allow_ssh_pub" {
  description = "Allow SSH inbound traffic from outside"
  vpc_id      = aws_vpc.my_vpc[0].id

  ingress {
    description = "SSH from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow_ssh_public"
  }
}

resource "aws_security_group" "allow_icmp_pub" {
  description = "Allow ICMP (ping) inbound traffic from internal networks"
  vpc_id      = aws_vpc.my_vpc[0].id

  ingress {
    description = "Allow ICMP (ping) inbound traffic from internal networks"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow_icmp_pub"
  }
}