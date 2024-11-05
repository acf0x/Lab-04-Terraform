output "nlb-endpoint" {
  description = "Endpoint de conexion al ELB externo (NLB)"
  value       = "https://${aws_lb.external-nlb.dns_name}"
}