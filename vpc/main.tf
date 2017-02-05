variable "name" {}
variable "env" {}
variable "domain"{}
variable "cidr" {}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC."
  default     = []
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "customer_gateway_ip" {
  default = ""
}
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

 tags {
    Name = "${var.name}"
    environment    = "${upper(var.env)}"
  }
}

############
## DHCP
############

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name = "${var.domain}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.domain}"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id ="${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
#############
## DNS
#############

resource "aws_route53_zone" "zone" {
  name   = "${var.domain}."
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name    = "${var.domain}-zone"
    environment    = "${upper(var.env)}"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.name}-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]
  tags {
    Name = "${var.name}-public"
    environment    = "${upper(var.env)}"
  }
}

resource "aws_route_table" "private" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  tags {
    Name = "${var.name}-private"
    environment    = "${upper(var.env)}"
  }
}

resource "aws_route" "public_route_igw" {
    route_table_id = "${aws_route_table.public.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc.id}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.private_subnets)}"

  tags {
    Name = "${var.name}-private"
    environment    = "${upper(var.env)}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.public_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.public_subnets)}"

  tags {
    Name = "${var.name}-public"
    environment    = "${upper(var.env)}"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "private_route_table_id" {
  value = "${aws_route_table.private.id}"
}
