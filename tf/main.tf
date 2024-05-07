terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.39.0"
    }
  }
}

provider "vault" {
}

data "vault_generic_secret" "stack_orchestration" {
  path = "secret/stack_orchestration"
}

provider "openstack" {
  auth_url  = data.vault_generic_secret.stack_orchestration.data["auth_url"]  
  password  = data.vault_generic_secret.stack_orchestration.data["password"]
  tenant_id = data.vault_generic_secret.stack_orchestration.data["project_id"]
  user_name = data.vault_generic_secret.stack_orchestration.data["username"]
}

resource "openstack_networking_secgroup_v2" "sec_group" {
  name        = "w_bot_docker_sec_group2"
}

resource "openstack_networking_secgroup_rule_v2" "sec_group_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 20000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sec_group.id
}

resource "openstack_compute_instance_v2" "w_bot_docker" {
  name              = "w_bot_docker"
  image_name        = var.image_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  security_groups   = [openstack_networking_secgroup_v2.sec_group.name]

  network {
    name = var.network_name
  }
}
