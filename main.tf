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
resource "ibm_compute_vm_instance" "test_vsi" {
    hostname = "anton-test-vsi"
    domain = "anton.com"
    os_reference_code = "UBUNTU_16_64"
    datacenter = "${var.datacenter}"
    network_speed = 10
    hourly_billing = true
    private_network_only = false
    cores = 1
    memory = 4096
    user_metadata = "{\"foo\":\"bar\"}"
    public_vlan_id = 1785525
    private_vlan_id = 1785527

    provisioner "remote-exec" {
      inline = [
        "apt-get upgrade",
        "apt-get update -y",
        "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -",
        "sudo apt-get install -y nodejs",
        "mkdir app",
        "touch app/anton.txt",
        "echo all done!"
      ]
    }

    connection {
      type = "ssh"
      host = "${self.test_vsi.ipv4_address}"
      user = "root"
      password = "asdasd"
    }
}

##############################################################################
# Outputs
##############################################################################
# output "ssh_key_id" {
#   value = "${ibm_compute_ssh_key.ssh_key.id}"
# }