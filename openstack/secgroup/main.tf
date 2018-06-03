variable name_prefix {}
variable secgroup_name {}

variable default_ports {
  default = ["22", "80", "443"]
}

variable extra_ports {
  default = ["8080", "8081"]
}

resource "openstack_networking_secgroup_v2" "created" {
  # create only if not specified in var.secgroup_name
  count       = "${var.secgroup_name == "" ? 1 : 0}"
  name        = "${var.name_prefix}-secgroup"
  description = "The automatically created secgroup for ${var.name_prefix}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  # create only if not specified in var.secgroup_name
  count       = "${var.secgroup_name == "" ? 1 : 0}"

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.created.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_http" {
  # create only if not specified in var.secgroup_name
  count       = "${var.secgroup_name == "" ? 1 : 0}"

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.created.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_defaults" {
  # create only if not specified in var.secgroup_name
  count       = "${var.secgroup_name == "" ? 1 : 0}"

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.created.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_extra" {
  # create only if not specified in var.secgroup_name
  count       = "${length(var.extra_ports)}"

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${element(var.extra_ports, count.index)}"
  port_range_max    = "${element(var.extra_ports, count.index)}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.created.id}"
}

output "secgroup_name" {
  # The join() hack is required because currently the ternary operator
  # evaluates the expressions on both branches of the condition before
  # returning a value. When providing and external VPC, the template VPC
  # resource gets a count of zero which triggers an evaluation error.
  #
  # This is tracked upstream: https://github.com/hashicorp/hil/issues/50
  #
  value = "${ var.secgroup_name == "" ? join(" ", openstack_compute_secgroup_v2.created.*.name) : var.secgroup_name }"
}
