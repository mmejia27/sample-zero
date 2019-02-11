###############################################################################
# VARIABLES
###############################################################################

###############################################################################
# / VARIABLES
###############################################################################

resource "aws_alb" "this_alb" {
  name            = "${var.environment}-${var.app_name}-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.this_alb.id}"]
}

resource "aws_alb_target_group" "this_target" {
  name     = "${var.environment}-${var.app_name}-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  slow_start           = 120
  deregistration_delay = 60

  health_check {
    path                = "/"
    timeout             = 10
    interval            = 20
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher              = "200-299"
  }
}

resource "aws_alb_listener" "this_listener" {
  load_balancer_arn = "${aws_alb.this_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.this_target.id}"
    type             = "forward"
  }
}
