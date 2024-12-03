output "monitoring_vm" {
  value = "http://${module.monitoring_vm.public_ip}"
}
