resource "aws_db_instance" "default" {

    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t3.micro"
    name                 = "mydb"
    username             = "foo"
    password             = "foobarbaz"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true
    db_subnet_group_name = aws_db_subnet_group.defaultrds.name
    vpc_security_group_ids = [ aws_security_group.db.id ]
    availability_zone = aws_subnet.private_vpc1.availability_zone
  
}

output "end_point" {
    value = aws_db_instance.default.endpoint
}