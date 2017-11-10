#The userdata script to start the instance with
data "template_file" "vpn_config" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    #psk      = "${var.psk}"
    network_block = "10.0.0.0/8"
    username      = "${var.username}"
    password      = "${var.password}"
  }
}
