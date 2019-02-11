###############################################################################
# VARIABLES
###############################################################################


###############################################################################
# / VARIABLES
###############################################################################

resource "aws_key_pair" "this_ec2_key" {
  key_name   = "${var.environment}-ec2-key"
  public_key = "${file("${var.public_ec2_key}")}"
}

data "aws_security_group" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "default"
}

resource "aws_security_group" "this_alb" {
  name        = "${var.environment}-${var.app_name}-alb"
  description = "Controls access to the ALB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "this_app" {
  name        = "${var.environment}-${var.app_name}-app"
  description = "Controls access to the app instances"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}