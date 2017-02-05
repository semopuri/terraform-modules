
## Subnets

variable "env"    {}
variable "vpc_id"{}

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

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.private_subnets)}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.env}-private"
    environment    = "${upper(var.env)}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.public_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.public_subnets)}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.env}-public"
    environment    = "${upper(var.env)}"
  }
  map_public_ip_on_launch = true
}
##output variables
output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}
