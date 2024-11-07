output "nlb-endpoint" {
  description = "Endpoint de conexion al ALB"
  value       = "https://${aws_lb.internal-alb.dns_name}"
}