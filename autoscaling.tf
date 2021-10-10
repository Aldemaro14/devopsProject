data "aws_availability_zones" "available" {}

# define AMI
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}
/*resource "aws_instance" "nginx" {
  ami           = "ami-0dba2cb6798deb6d8"
  subnet_id = [aws_subnet.public_vpc1.id, aws_subnet.public_vpc2.id]
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_group = [aws_security_group.custom_instance_sg.id]
  key_name = "devops"

  provisioner "remote-exec" {
      inline = ["echo 'wait intil SSH is ready'"]

      connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file("devops.pem")
          host = aws_instance.nginx.public_ip
      }
  }

  provisioner "local-exec" {

      command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key devops.pem nginx.yaml"
    
  }

  output "nginx_ip" {
      value = aws_instance.nginx.public_ip
  }
}*/

resource "aws_launch_configuration" "custom_launch_configuration" {

    name = "custom-launch-configuration"
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"

    lifecycle {
        create_before_destroy = true
    }
  
}

# define autoscaling group
resource "aws_autoscaling_group" "custom_group_autoscaling" {

    name = "custom_group_autoscaling"
    vpc_zone_identifier = [aws_subnet.public_vpc1.id, aws_subnet.public_vpc2.id]
    launch_configuration = aws_launch_configuration.custom_launch_configuration.id
    min_size = 2
    max_size = 2
    health_check_grace_period = 100
    health_check_type = "ELB"
    load_balancers = [aws_elb.custom_elb.name]
    tag {
        key = "Name"
        value = "custom_ec2_instance"
        propagate_at_launch = true
    }
}

resource "aws_db_parameter_group" "default_parameter_group" {

    name = "madiadb"
    family = "mariadb10.2"

    parameter {
      name = "max_allowed_packet"
      value = "16777216"
    }
  
}

resource "aws_db_subnet_group" "defaultrds" {

    name = "main_rds"
    subnet_ids = [ aws_subnet.public_vpc1.id, aws_subnet.public_vpc2.id ]

    tags = {
        Name = "my_DB_subnet_group"
    }
  
}

output "elb" {

    value = aws_elb.custom_elb.dns_name
  
}