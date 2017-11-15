##############################################################################
# Require terraform 0.9.3 or greater
##############################################################################
terraform {
  required_version = ">= 0.9.3"
}

##############################################################################
# Variables
##############################################################################
variable bxapikey {
  description = "Your Bluemix API key."
}
variable slusername {
  description = "Your Bluemix Infrastructure (SoftLayer) user name."
}
variable slapikey {
  description = "Your Bluemix Infrastructure (SoftLayer) API key."
}
variable datacenter {
  description = "The data center that you want to create resources in."
}
variable public_vlan_id {
  description = "Public VLAN ID"
}
variable private_vlan_id {
  description = "Private VLAN ID"
}
variable load_balancer_subnet {
  description = "Subnet ID for load balancer"
}
variable schematics_environment_name {
  description = "This value used for VSI provisioning script. Do not modify."
  default = "$SCHEMATICS.ENV"
}
variable schematics_ssh_key_public {
  description = "This value used for VSI provisioning script. Do not modify."
  default = "$SCHEMATICS.SSHKEYPUBLIC"
}
variable schematics_ssh_key_private {
  description = "This value used for VSI provisioning script. Do not modify."
  default = "$SCHEMATICS.SSHKEYPRIVATE"
}

##############################################################################
# IBM Cloud Provider
##############################################################################
provider "ibm" {
  bluemix_api_key = "${var.bxapikey}"
  softlayer_username = "${var.slusername}"
  softlayer_api_key = "${var.slapikey}"
}

##############################################################################
# Resources
##############################################################################
resource "ibm_compute_ssh_key" "schematics_ssh_public_key" {
    label = "Schematics SSH key for ${var.schematics_environment_name}"
    public_key = "${var.schematics_ssh_key_public}"
}

resource "ibm_compute_vm_instance" "vsi_instances" {
    count = 2
    hostname = "devex-test-vsi-${count.index}"
    domain = "devex.com"
    os_reference_code = "UBUNTU_16_64"
    datacenter = "${var.datacenter}"
    network_speed = 10
    hourly_billing = true
    private_network_only = false
    cores = 1
    memory = 4096
    user_metadata = "{\"foo\":\"bar\"}"
    public_vlan_id = "${var.public_vlan_id}"
    private_vlan_id = "${var.private_vlan_id}"
    ssh_key_ids = [ "${ibm_compute_ssh_key.schematics_ssh_public_key.id}" ]

    connection {
      user = "root"
      private_key = "${var.schematics_ssh_key_private}"
    }

    provisioner "remote-exec" {
      inline = [
        "apt-get update -y",
        "apt-get upgrade -y",
        "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -",
        "sudo apt-get install -y nodejs",
        "mkdir app"
      ]
    }
}

resource "ibm_lbaas" "load_balancer" {
  name        = "LoadBalancer"
  subnets     = ["${var.load_balancer_subnet}"]

  protocols = [
    {
      frontend_protocol     = "HTTP"
      frontend_port         = 3000
      backend_protocol      = "HTTP"
      backend_port          = 3000
      load_balancing_method = "round_robin"
    }
  ]

  server_instances = [
    { 
      "private_ip_address" = "${ibm_compute_vm_instance.vsi_instances.0.ipv4_address_private}"
    },
    { 
      "private_ip_address" = "${ibm_compute_vm_instance.vsi_instances.1.ipv4_address_private}"
    }

  ]
}


##############################################################################
# Outputs
##############################################################################
output "ssh_key_id" {
  value = "${ibm_compute_ssh_key.schematics_ssh_public_key.id}"
}

output "vm_instance_ids" {
  value = "${join(" ", ibm_compute_vm_instance.vsi_instances.*.id)}"
}

output "vm_instance_ipv4_addresses" {
  value = "${join(" ", ibm_compute_vm_instance.vsi_instances.*.ipv4_address)}"
}

output "private_key" {
  value = "${var.schematics_ssh_key_private}"
}

output "public_key" {
  value = "${var.schematics_ssh_key_public}"
}