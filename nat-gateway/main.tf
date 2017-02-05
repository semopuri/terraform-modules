##Create NAT gateway##
variable public_subnet_id {}

resource "aws_eip" "nat" {
  vpc   = true
  lifecycle { prevent_destroy = true }
}

resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${var.public_subnet_id}"
    lifecycle { create_before_destroy = true }
}
output "nat_gw_id" {
 value = "${aws_nat_gateway.gw.id}"
}
