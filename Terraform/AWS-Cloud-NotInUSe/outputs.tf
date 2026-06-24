output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = data.aws_eip.existing.public_ip
}
/* If creating new IP 
output "public_ip" {
  value = aws_eip.maestro_ip.public_ip
}
*/
output "private_key_path" {
  value = local_file.private_key_pem.filename
}
