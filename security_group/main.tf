variable name {}

resource "aws_security_group" "security_group" {
  name   = "${var.name}-sg"
  vpc_id = "${var.vpc_id}"
  lifecycle { create_before_destroy = true }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name         = "${var.name}-sg"
    Environment  = "${var.env}"
  }
}
output "sg_id"   { value = "${aws_security_group.security_group.id}" }variable env{}
