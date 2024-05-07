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
  name      = "w_bot_sec_group"
}

resource "openstack_networking_secgroup_rule_v2" "sec_group_ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sec_group.id
}

resource "openstack_networking_secgroup_rule_v2" "sec_group_http_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sec_group.id
}

# Security group rule for https
resource "openstack_networking_secgroup_rule_v2" "sec_group_https_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sec_group.id
}

resource "openstack_compute_instance_v2" "w_bot" {
  name              = "w_bot"
  image_name        = var.image_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  security_groups   = [openstack_networking_secgroup_v2.sec_group.name]

  network {
    name            = var.network_name
  }
}
