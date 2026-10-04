resource "aws_security_group" "app_sg" {
  name = "app-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "app_sg" {
    security_group_id = aws_security_group.app_sg.id
    referenced_security_group_id = aws_security_group.lb_sg.id
    from_port = 443
    to_port = 443
    protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_sg" {
  security_group_id = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.lb_sg.id
  from_port = 8000
  to_port = 8000
  protocol = "tcp"
}

resource "aws_security" "lb_sg" {
  name = "lb_sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg" {
  security_group_id = aws_security_group.lb_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port = 8000
  to_port = 8000
  protocol = "tcp"
}

