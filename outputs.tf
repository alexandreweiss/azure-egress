output "monitoring_vm" {
  value = "http://${module.monitoring_vm.public_ip}"
}

output "ilpip_vm" {
  value = "http://${module.ilpip_vm.public_ip}"
}
