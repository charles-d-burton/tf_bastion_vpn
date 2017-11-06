# Bastion

resource "aws_instance" "bastion" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  subnet                      = "${var.subnet}"
  associate_public_ip_address = "true"
  userdata                    = "${data.template_file.vpn_config.rendered}"

  tags {
    Name = "Terraform Bastion Host"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Basion Inbound"
  vpc_id      = "${var.vpc_id}"

  #SSH Remote Port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #UDP for the VPN Tunnel
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #This is for outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "TerraformBastionSecurityGroup"
  }
}
