variable "key_name" {
  description = " SSH keys to connect to ec2 instance"
  default     =  "your_pem_keyname"
}

variable "instance_type" {
  description = "instance type for ec2"
  default     =  "t2.micro"
}