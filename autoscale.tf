###############################################################################
# VARIABLES
###############################################################################

###############################################################################
# / VARIABLES
###############################################################################


###############################################################################
# DATA
###############################################################################
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}


###############################################################################
# / DATA
###############################################################################

###############################################################################
# LAUNCH CONFIG
###############################################################################
resource "aws_launch_configuration" "this_lc" {
  name_prefix                 = "${var.environment}-${var.autoscale_name}-lc-"
  image_id                    = "${coalesce(var.autoscale_image_id, data.aws_ami.amazon_linux.id)}"
  instance_type               = "${var.autoscale_instance_type}"
  #iam_instance_profile        = "${var.autoscale_iam_instance_profile}"
  key_name                    = "${aws_key_pair.this_ec2_key.key_name}"
  security_groups             = ["${aws_security_group.this_app.id}"]
  associate_public_ip_address = "${var.autoscale_associate_public_ip_address}"
  user_data                   = "${file("${var.autoscale_user_data_file}")}"
  enable_monitoring           = "${var.autoscale_enable_monitoring}"

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# / LAUNCH CONFIG
###############################################################################


###############################################################################
# AUTOSCALING GROUP
###############################################################################
resource "aws_autoscaling_group" "this_asg" {
  name_prefix          = "${aws_launch_configuration.this_lc.name}-asg-"
  launch_configuration = "${aws_launch_configuration.this_lc.name}"
  vpc_zone_identifier  = ["${aws_subnet.private.*.id}"]
  max_size             = "${var.autoscale_max_size}"
  min_size             = "${var.autoscale_min_size}"
  desired_capacity     = "${var.autoscale_desired_capacity}"

  load_balancers            = ["${var.autoscale_load_balancers}"]
  health_check_grace_period = "${var.autoscale_health_check_grace_period}"
  health_check_type         = "${var.autoscale_health_check_type}"

  min_elb_capacity          = "${var.autoscale_min_elb_capacity}"
  wait_for_elb_capacity     = "${var.autoscale_wait_for_elb_capacity}"
  target_group_arns         = ["${aws_alb_target_group.this_target.arn}"]
  default_cooldown          = "${var.autoscale_default_cooldown}"
  force_delete              = "${var.autoscale_force_delete}"
  termination_policies      = "${var.autoscale_termination_policies}"
  suspended_processes       = "${var.autoscale_suspended_processes}"
  placement_group           = "${var.autoscale_placement_group}"
  enabled_metrics           = ["${var.autoscale_enabled_metrics}"]
  metrics_granularity       = "${var.autoscale_metrics_granularity}"
  wait_for_capacity_timeout = "${var.autoscale_wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.autoscale_protect_from_scale_in}"


  lifecycle {
    create_before_destroy = true
  }
}
###############################################################################
# / AUTOSCALING GROUP
###############################################################################
