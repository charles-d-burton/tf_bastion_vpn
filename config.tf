#The userdata script to start the instance with
data "template_file" "vpn_config" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    network_block = "${var.network_block}"
    gateway       = "${var.gateway}"
    cidr          = "${var.cidr}"
    netmask       = "${var.netmask}"
  }
}
