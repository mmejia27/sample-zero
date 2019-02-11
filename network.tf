###############################################################################
# VARIABLES
###############################################################################
locals {
  use_nat_gateway = "${ var.network_nat_type == "gateway" ? true : false }"
}

data "aws_ami" "nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  owners = ["amazon"]
}

###############################################################################
# / VARIABLES
###############################################################################

# Create a VPC for environment
resource "aws_vpc" "vpc" {
  cidr_block = "${var.network_cidr}"

  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

# Create an internet gateway to give internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags {
    Name        = "${var.environment}-default-route-table"
    Environment = "${var.environment}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

# Create a public subnet to launch our instances into
resource "aws_subnet" "public" {
  count                   = "${var.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.network_cidr, 8, count.index)}"
  availability_zone       = "${var.az_names[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.environment}-public-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

# Create a private subnet to launch our instances into
resource "aws_subnet" "private" {
  count                   = "${var.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.network_cidr, 8, count.index + 10)}"
  availability_zone       = "${var.az_names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.environment}-private-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

# Create EIP for NAT Gateways/Instances to use
resource "aws_eip" "nat_ip" {
  count = "${var.az_count}"
  vpc   = true

  depends_on = ["aws_internet_gateway.igw"]

  tags {
    Name = "${var.environment}-nat-ip-${count.index + 1}"
  }
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  count         = "${local.use_nat_gateway ? var.az_count : 0}"
  allocation_id = "${element(aws_eip.nat_ip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create NAT Instances
resource "aws_security_group" "nat_instances" {
  count       = "${local.use_nat_gateway ? 0 : 1}"
  name        = "${var.environment}-nat-intance-sg"
  description = "Controls access for the NAT instances"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "nat_instance" {
  count                       = "${local.use_nat_gateway ? 0 : var.az_count}"
  ami                         = "${data.aws_ami.nat.id}"
  instance_type               = "${var.nat_instance_type}"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.nat_instances.id}"]
  key_name                    = "${aws_key_pair.this_ec2_key.key_name}"
  source_dest_check           = false
  associate_public_ip_address = true

  tags {
    Name = "${var.environment}-nat-intance-${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "nat_eip_assoc" {
  count         = "${local.use_nat_gateway ? 0 : var.az_count}"
  instance_id   = "${element(aws_instance.nat_instance.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat_ip.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-private-route-table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count         = "${var.az_count}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route" "private" {
  count         = "${local.use_nat_gateway ? var.az_count : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_instances" {
  count         = "${local.use_nat_gateway ? 0 : var.az_count}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  instance_id            = "${element(aws_instance.nat_instance.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"

  depends_on = ["aws_instance.nat_instance"]
}
