resource "aws_instance" "instance" {
    count                       = "${var.count}"
    ami                         = "${var.ami}"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${var.subnet_id}"
    instance_type               = "${var.instance_type}"
    private_ip                  = "${var.private_ip}"
    availability_zone           = "${var.az}"
    vpc_security_group_ids      = ["${var.security_group_id}"]
    iam_instance_profile        = "${var.iam_instance_profile}"
    associate_public_ip_address = "${var.associate_public_ip}"
    source_dest_check           = "${var.source_dest_check}"

    tags {
        Name            = "${var.name}-${count.index}"
        env             = "${var.environment_tag}"
        ansibleFilter   = "${var.ansibleFilter_tag}"
        ansibleNodeType = "${var.name}"
        ansibleNodeName = "${var.name}${count.index}"

    }
output "private_ip" { value = "${join(",",aws_instance.instance.*.private_ip)}" }
output "id"         { value = "${join(",", aws_instance.instance.*.id)}"}
