# key pair (login)
resource aws_key_pair my-key{
    key_name = "terra-key-ansible"
    public_key = file("terra-key-ansible.pub")

}

# VPC & Security group
resource aws_default_vpc default {

  
}

resource aws_security_group my_security_group {
  name = "automate-sg"
  description = "This will add a TF generated Security group"
  vpc_id = aws_default_vpc.default.id  #interpolation

    #inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH open"

    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP open"
    }

    #outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "all access open outbound"
    }


    tags = {
        Name = "automate-sg"
    }

}


# ec2 instance

resource "aws_instance" "my_instance" {
    #count = 2  #meta argument
    for_each = tomap({
        ansible-Master  = "ami-0d1b5a8c13042c939", #ubuntu
        ansible-1 = "ami-0d1b5a8c13042c939", #ubuntu
        ansible-2  = "ami-068d5d5ed1eeea07c", #redhat
        ansible-3  = "ami-0eb9d6fc9fab44d24", #amazon linux
    })

    depends_on = [ aws_security_group.my_security_group, aws_key_pair.my-key ]
    key_name = aws_key_pair.my-key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = "t2.micro"
    ami = each.value
    #user_data = file("install_nginx.sh")

    root_block_device {
      volume_size = 12
      volume_type = "gp3"
    }
    tags = {
        Name = each.key
    }
  
}