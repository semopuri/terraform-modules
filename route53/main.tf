resource "aws_route53_zone" "zone" {
  name   = "${var.domain}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name    = "${var.domain}-zone"
    owner   = "${var.owner}"
  }
}
