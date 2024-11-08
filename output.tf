output "alb-endpoint" {
  description = "Endpoint de conexion al ALB"
  value       = "https://${aws_lb.internal-alb.dns_name}"
}

output "rds-endpoint" {
  description = "Endpoint conexion interna a RDS"
  value       = aws_route53_record.rds-record.name
}

output "redis-endpoint" {
  description = "Endpoint de conexion interna a Redis"
  value       = aws_route53_record.redis-record.name
}

output "memcached-endpoint" {
  description = "Endpoint de conexion interna a Memcached"
  value       = aws_route53_record.memcached-record.name
}

output "nlb-endpoint" {
  description = "Endpoint de conexion al NLB"
  value       = "https://${aws_lb.external-nlb.dns_name}"
}
output "cloudfront-endpoint" {
  description = "Endpoint de conexion al CloudFront"
  value       = "https://${aws_cloudfront_distribution.cf-distribution.domain_name}"
}