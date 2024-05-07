output "instance_ip_addr" {
  value = openstack_compute_instance_v2.w_bot.access_ip_v4
}
