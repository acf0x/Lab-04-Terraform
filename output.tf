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

output "zzz-nlb-endpoint" {
  description = "Endpoint de conexion al NLB"
  value       = "https://${aws_lb.external-nlb.dns_name}"
}
output "zzz-cloudfront-endpoint" {
  description = "Endpoint de conexion al CloudFront"
  value       = "https://${aws_cloudfront_distribution.cf-distribution.domain_name} | No he conseguido que redirija al NLB con SSL autofirmado end to end. Conectar directamente al NLB en su lugar para verificar que funciona."
}

output "vpc-main-id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.vpc-main.id
}

output "vpc-main-cidr" {
  description = "CIDR block de la VPC principal"
  value       = aws_vpc.vpc-main.cidr_block
}

output "vpc-backup-id" {
  description = "ID de la VPC de backups"
  value       = aws_vpc.vpc-backup.id
}

output "vpc-backup-cidr" {
  description = "CIDR block de la VPC de backups"
  value       = aws_vpc.vpc-backup.cidr_block
}

output "public-subnet-1-id" {
  description = "ID de la subred publica 1"
  value       = aws_subnet.public-subnet-1.id
}

output "public-subnet-2-id" {
  description = "ID de la subred publica 2"
  value       = aws_subnet.public-subnet-2.id
}

output "private-subnet-1-id" {
  description = "ID de la subred privada 1"
  value       = aws_subnet.private-subnet-1.id
}

output "private-subnet-2-id" {
  description = "ID de la subred privada 2"
  value       = aws_subnet.private-subnet-2.id
}

output "private-subnet-backup-1-id" {
  description = "ID de la subred privada 1"
  value       = aws_subnet.private-subnet-backup-1.id
}

output "private-subnet-2-backup-id" {
  description = "ID de la subred privada 2"
  value       = aws_subnet.private-subnet-backup-2.id
}

output "igw-id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.igw-main.id
}

output "natgw-1-id" {
  description = "ID del NAT Gateway 1"
  value       = aws_nat_gateway.natgw-1.id
}

output "natgw-2-id" {
  description = "ID del NAT Gateway 2"
  value       = aws_nat_gateway.natgw-2.id
}

output "acm-certificate-arn" {
  description = "ARN del certificado ACM"
  value       = aws_acm_certificate.acm-certificate-lab04.arn
}

output "s3-bucket-name" {
  description = "Nombre del bucket de S3"
  value       = aws_s3_bucket.bucket.id
}

output "kms-key-id" {
  description = "ARN de la clave KMS generada de manera dinamica"
  value       = aws_kms_key.kms-key.arn
}

output "secrets-manager-secret-arn" {
  description = "ARN del secreto en Secrets Manager"
  value       = aws_secretsmanager_secret.db-secret.arn
}

output "rds-instance-endpoint" {
  description = "Endpoint de conexion a la instancia RDS"
  value       = aws_db_instance.rds.endpoint
}

output "rds-replica-endpoint" {
  description = "Endpoint de conexion a la replica de RDS"
  value       = aws_db_instance.rds-replica.endpoint
}

output "efs-file-system-id" {
  description = "ID del sistema de archivos EFS"
  value       = aws_efs_file_system.efs.id
}

output "asg-name" {
  description = "Nombre del Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "asg-min-size" {
  description = "Tamaño minimo del Auto Scaling Group"
  value       = aws_autoscaling_group.asg.min_size
}

output "asg-max-size" {
  description = "Tamaño maximo del Auto Scaling Group"
  value       = aws_autoscaling_group.asg.max_size
}

output "asg_instance_ids" {
  description = "IDs de las instancias asociadas al Auto Scaling Group"
  value = join(", ", data.aws_instances.asg_instances.ids)
}