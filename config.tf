#The userdata script to start the instance with
data "template_file" "vpn_config" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    psk      = "${var.psk}"
    username = "${var.username}"
    password = "${var.password}"
  }
}
