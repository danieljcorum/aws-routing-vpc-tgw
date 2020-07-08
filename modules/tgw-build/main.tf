resource "aws_vpc" "vpc-1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
    env = var.env
  }
}

# Subnets
resource "aws_subnet" "vpc-1-sub-a" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = var.subnet_a
  availability_zone = var.az1

  tags = {
    Name = "${aws_vpc.vpc-1.tags.Name}-subnet-a"
  }
}

resource "aws_subnet" "vpc-1-sub-c" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = var.subnet_c
  availability_zone = var.az2

  tags = {
    Name = "${aws_vpc.vpc-1.tags.Name}-sub-c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc-1-igw" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "vpc-1-igw"
    Env = var.env
  }
}

# Main Route Tables Associations
## Forcing our Route Tables to be the main ones for our VPCs,
## otherwise AWS automatically will create a main Route Table
## for each VPC, leaving our own Route Tables as secondary

resource "aws_main_route_table_association" "main-rt-vpc-1" {
  vpc_id         = aws_vpc.vpc-1.id
  route_table_id = aws_route_table.vpc-1-rtb.id
}

# Route Tables
## Usually unecessary to explicitly create a Route Table in Terraform
## since AWS automatically creates and assigns a 'Main Route Table'
## whenever a VPC is created. However, in a Transit Gateway scenario,
## Route Tables are explicitly created so an extra route to the
## Transit Gateway could be defined

resource "aws_route_table" "vpc-1-rtb" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name       = "${var.env}-vpc-1-rtb"
    Env        = var.env
  }
  depends_on = [aws_ec2_transit_gateway.tgw]
}

###########################
# Transit Gateway Section #
###########################

# Transit Gateway
## The default setup being a full mesh scenario where all VPCs can see every other
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = var.tgw_desc
  dns_support                = "enable"
  vpn_ecmp_support               = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  auto_accept_shared_attachments  = "enable"
  tags                            = {
    Name                          = var.tgw_name
    description                   = var.tgw_desc
  }
}

# Add Route Tables
resource "aws_ec2_transit_gateway_route_table" "tgw-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags               = {
    Name        = var.tgw_rt_name
  }
  depends_on = [aws_ec2_transit_gateway.tgw]
}

# Add Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-1-att" {
  subnet_ids = ["${aws_subnet.vpc-1-sub-a.id}","${aws_subnet.vpc-1-sub-c.id}"]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id = aws_vpc.vpc-1.id
  dns_support = "enable"
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "true"
  tags = {
    Name = "${var.env}-vpc-att"
  }
}

# Associate attachment to route Table
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-1-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-1-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt.id
}
