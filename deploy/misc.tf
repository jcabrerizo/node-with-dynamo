
resource "random_string" "salt_generated" {
  length = 4
  numeric = false
  upper = false
  special = false
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  prefix = "${var.prefix_identifier}-${length(var.salt_override) > 0 ? var.salt_override : random_string.salt_generated.result}"
}
