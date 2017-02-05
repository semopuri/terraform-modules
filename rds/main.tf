resource "aws_db_parameter_group" "mysql-parameters" {
  name = "${lower(var.env)}"
  family = "mysql5.6"
}
resource "aws_db_instance" "main_rds_instance" {
    identifier = "${var.rds_instance_name}"
    allocated_storage = "${var.rds_allocated_storage}"
    engine = "${var.rds_engine_type}"
    engine_version = "${var.rds_engine_version}"
    instance_class = "${var.rds_instance_class}"
    name = "${var.rds_database_name}"
    username = "${var.rds_database_user}"
    password = "${var.rds_database_password}"
    // Because we're assuming a VPC, we use this option, but only one SG id
    vpc_security_group_ids = ["${var.rds_security_group_id}"]
    // We're creating a subnet group in the module and passing in the name
    db_subnet_group_name = "${aws_db_subnet_group.main_db_subnet_group.name}"
    parameter_group_name = "${aws_db_parameter_group.mysql-parameters.name}"
    // We want the multi-az setting to be toggleable, but off by default
    multi_az = "${var.rds_is_multi_az}"
    storage_type = "${var.rds_storage_type}"
    backup_retention_period = "${var.rds_backup_retention_period}"
    maintenance_window = "${var.rds_maintenance_window}"
    backup_window = "${var.rds_backup_window}"
}

resource "aws_db_subnet_group" "main_db_subnet_group" {
    name = "${var.rds_instance_name}-subnetgroup"
    description = "RDS subnet group"
    subnet_ids = ["${var.rds_subnets}"]
}
## Module: tf_aws_rds ##

// Output the ID of the RDS instance
output "rds_instance_id" {
    value = "${aws_db_instance.main_rds_instance.id}"
}

// Output the Address of the RDS instance
output "rds_instance_address" {
    value = "${aws_db_instance.main_rds_instance.address}"
}

// Output the ID of the Subnet Group
output "subnet_group_id" {
    value = "${aws_db_subnet_group.main_db_subnet_group.id}"
}
variable "env"{}
variable "rds_instance_name"{}
variable "rds_instance_class" {}
variable "rds_database_name" {
    description = "The name of the database to create"
}

variable "rds_database_user" {}
variable "rds_database_password" {}
variable "rds_is_multi_az" {
    default = "false"
}

variable "rds_storage_type" {
    default = "standard"
}

variable "rds_allocated_storage" {
    description = "The allocated storage in GBs"
    // You just give it the number, e.g. 10
}
variable "rds_engine_type" {
    // Valid types are
    // - mysql
    // - postgres
    // - oracle-*
    // - sqlserver-*
    // See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
    // --engine
}

variable "rds_engine_version" {
    // For valid engine versions, see:
    // See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
    // --engine-version

}
variable "rds_security_group_id" {
  default = []
}

// RDS Subnet Group Variables
variable "rds_subnets" {
  description = "RDS Subnet Group Variables"
  default     = []
}

variable "rds_backup_retention_period" {}

variable "rds_maintenance_window" {}

variable "rds_backup_window" {}
