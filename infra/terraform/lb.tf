resource "aws_lb" "lb" {
  name = "lb"
  load_balancer_type = "application"
  internal = false

  subnets = [aws_subnet.public_1.id,
  aws_subnet.public_2.id]
  security_groups = [aws_security_group.app_lb.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port = 8000
  protocol = "tcp"

  certificate_arn = aws_acm_certificate_validation.lab.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.HTTP.arn
  } 
}

resource "aws_lb_target_group" "HTTP" {
  name = "tg"
  protocol = "HTTP" 
  port = 30080
  vpc_id = aws_vpc.main.id 
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    enabled         = false
    cookie_duration = 86400
  }

  health_check {
    path = "/health"
    port = "traffic-port"
  }

  deregistration_delay = 60
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id = kubernetes_service.service.id
}


# ------------------------------------------------------
resource "aws_launch_template" "lab_workers" {
  name_prefix   = "lab-workers-"
  image_id      = "ami-xxxxxxxx"
  instance_type = "t3.medium"
}

resource "aws_autoscaling_group" "lab_workers" {
  name = "lab-workers-asg"

  min_size         = 2
  max_size         = 6
  desired_capacity = 3

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.lab_workers.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.lab.arn
  ]

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 60
    }
  }
}


resource "aws_autoscaling_schedule" "scale_out_before_campaign" {
  scheduled_action_name  = "campaign-scale-out"
  autoscaling_group_name = aws_autoscaling_group.lab_workers.name

  min_size         = 6
  desired_capacity = 6
  max_size         = 10

  recurrence = "45 13 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_after_campaign" {
  scheduled_action_name  = "campaign-scale-in"
  autoscaling_group_name = aws_autoscaling_group.lab_workers.name

  min_size         = 2
  desired_capacity = 2
  max_size         = 10

  recurrence = "0 17 * * *"
}

resource "aws_autoscaling_warm_pool" "lab" {
  autoscaling_group_name = aws_autoscaling_group.lab_workers.name

  pool_state = "Stopped"

  min_size = 2

  max_group_prepared_capacity = 6

  instance_reuse_policy {
    reuse_on_scale_in = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "terminate" {
  name                   = "lab-graceful-termination"
  autoscaling_group_name = aws_autoscaling_group.lab.name

  lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout     = 120
  default_result        = "CONTINUE"
}

resource "aws_autoscaling_policy" "requests" {
  name                   = "lab-request-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.lab.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 120

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${aws_lb.lab.arn_suffix}/${aws_lb_target_group.lab.arn_suffix}"
    }

    target_value     = 1000
    disable_scale_in = false
  }
}


# ------------------------------------------------------

resource "aws_wafv2_web_acl" "lab" {
  name  = "lab-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {

  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "lab-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "lab" {
  resource_arn = aws_lb.lab.arn
  web_acl_arn  = aws_wafv2_web_acl.lab.arn
}



# -------------------------------------------------------------

data "aws_route53_zone" "lab" {
  name         = "lab-example.com"
  private_zone = false
}

resource "aws_route53_zone" "lab" {
  name = "lab-example.com"
}

resource "aws_acm_certificate" "lab" {
  domain_name       = "api.lab-example.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.lab.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.lab.zone_id

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]

  ttl = 60
}

resource "aws_acm_certificate_validation" "lab" {
  certificate_arn = aws_acm_certificate.lab.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}

# ----------------------------------------------------------------
