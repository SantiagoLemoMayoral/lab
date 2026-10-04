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
  health_check {

  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id = kubernetes_service.service.id
}

