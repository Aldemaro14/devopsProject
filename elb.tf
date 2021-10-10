# Create a new load balancer
resource "aws_elb" "custom_elb" {
  name = "custom-elb"
  subnets = [aws_subnet.public_vpc1.id,aws_subnet.public_vpc2.id]
  security_groups = [aws_security_group.custom_elb_sg.id]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "custom_elb"
  }
}

# security group for ELB
resource "aws_security_group" "custom_elb_sg" {

    vpc_id = aws_vpc.testvpc.id
    name = "custom-elbsg"
    description = "security group for ELB"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "custom_elb_sg"
    }
  
}

# security group for instances
resource "aws_security_group" "custom_instance_sg" {

    vpc_id = aws_vpc.testvpc.id
    name = "custom_instance_sg"
    description = "security group for instances"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.custom_elb_sg.id]
    }

    tags = {
        Name = "custom_instance_sg"
    }
  
}

resource "aws_security_group" "db" {

    name = "allow_SSH"
    description = "Allow SSH inbound traffic"
    vpc_id = aws_vpc.testvpc.id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  
}
