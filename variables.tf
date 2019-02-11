variable "aws_region" {
  default     = "us-east-1"
}

variable "environment" {
  description = "Name for environment"
  default     = "dev"
}

variable "network_cidr" {
  default = "10.10.0.0/16"
}

variable "az_count" {
  default = "4"
}

variable "az_names" {
  type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "public_ec2_key" {
  description = "File path to the development pubic key to use for authentication on instances"
  default = "../../../security/testing.pub"
}

variable "network_nat_type" {
  type    = "string"
  default = "instance"
}

variable "nat_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "app_name" {
  default = "testing"
}

variable "autoscale_name" {
  description = "Name for autoscale group and launch configuration"
  default     = "testing"
}

# variable "autoscale_iam_instance_profile" {
#   description = "IAM instance profile for launch configuration"
# }

# variable "autoscale_security_groups" {
#   default = []
# }

variable "autoscale_associate_public_ip_address" {
  default = false
}

variable "autoscale_user_data_file" {
  default = "user-data.yml"
}

variable "autoscale_enable_monitoring" {
  default = false
}

variable "autoscale_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "autoscale_image_id" {
  description = "Image ID to use in launch configuration"
  default = ""
}

variable "autoscale_max_size" {
  description = "Maximum size for autoscaling group"
  default     = 3
}

variable "autoscale_min_size" {
  description = "Minimum size for autoscaling group"
  default     = 3
}

variable "autoscale_desired_capacity" {
  description = "Desired size for autoscaling group"
  default     = 3
}

variable "autoscale_health_check_grace_period" {
  default = 60
}

variable "autoscale_health_check_type" {
  default = "ELB"
}

variable "autoscale_min_elb_capacity" {
  default = 0
}

variable "autoscale_wait_for_elb_capacity" {
  default = 1
}

variable "autoscale_load_balancers" {
  default = []
}

variable "autoscale_target_group_arns" {
  default = []
}

variable "autoscale_default_cooldown" {
  default = 60
}

variable "autoscale_force_delete" {
  default = false
}

variable "autoscale_termination_policies" {
  type    = "list"
  default = ["Default"]
}

variable "autoscale_suspended_processes" {
  default = []
}

variable "autoscale_placement_group" {
  default = ""
}

variable "autoscale_enabled_metrics" {
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "autoscale_metrics_granularity" {
  default = "1Minute"
}

variable "autoscale_wait_for_capacity_timeout" {
  default = "5m"
}

variable "autoscale_protect_from_scale_in" {
  default = false
}
