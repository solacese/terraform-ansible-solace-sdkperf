output "sdkperf-node-public-ips" {
  value = ["${aws_instance.sdkperf-nodes.*.public_ip}"]
}
output "sdkperf-node-private-ips" {
  value = ["${aws_instance.sdkperf-nodes.*.private_ip}"]
}

output "solace-broker-primary-public-ips" {
  value = ["${aws_instance.solace-broker-primary.*.public_ip}"]
}
output "solace-broker-primary-private-ips" {
  value = ["${aws_instance.solace-broker-primary.*.private_ip}"]
}

output "solace-broker-backup-public-ips" {
  value = ["${aws_instance.solace-broker-backup.*.public_ip}"]
}
output "solace-broker-backup-private-ips" {
  value = ["${aws_instance.solace-broker-backup.*.private_ip}"]
}

output "solace-broker-monitor-public-ips" {
  value = ["${aws_instance.solace-broker-monitor.*.public_ip}"]
}
output "solace-broker-monitor-private-ips" {
  value = ["${aws_instance.solace-broker-monitor.*.private_ip}"]
}