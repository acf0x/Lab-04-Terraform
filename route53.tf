/*=========================================
=                Route 53                 =
=========================================*/

/* Crear una zona en Route53
   Gestiona registros DNS privados para los servicios en AWS */

resource "aws_route53_zone" "route53-zone" {
  name = "acflab04.com" # Nombre del dominio
  vpc {
    vpc_id = aws_vpc.vpc-main.id # Asociar zona a la VPC principal
  }

  tags = {
    Name          = "route53-zone-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "route53"
  }
}

/* Crear registros DNS privados para servicios especificos en el dominio */

/* ELB externo (NLB) */
resource "aws_route53_record" "nlb-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "nlb.acflab04.com" # Subdominio para el NLB
  type    = "A"

  alias {
    name                   = aws_lb.external-nlb.dns_name
    zone_id                = aws_lb.external-nlb.zone_id
    evaluate_target_health = true
  }
}

/* ELB interno (ALB) */
resource "aws_route53_record" "alb-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "alb.acflab04.com" # Subdominio para el ALB
  type    = "A"

  alias {
    name                   = aws_lb.internal-alb.dns_name
    zone_id                = aws_lb.internal-alb.zone_id
    evaluate_target_health = true
  }
}

/* Instancia RDS */
resource "aws_route53_record" "rds-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "db.acflab04.com" # Subdominio para la instancia RDS
  type    = "CNAME"
  ttl     = 300                                           # Tiempo de vida del registro DNS
  records = [split(":", aws_db_instance.rds.endpoint)[0]] # Obtener DNS de RDS sin el puerto
}

/* Memcached */
resource "aws_route53_record" "memcached-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "memcached.acflab04.com" # Subdominio para Memcached
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_cluster.memcached.configuration_endpoint] # Obtener DNS de Memcached
}

/* Redis */
resource "aws_route53_record" "redis-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "redis.acflab04.com" # Subdominio para Redis
  type    = "CNAME"
  ttl     = 300                                                                # Tiempo de vida del registro DNS
  records = [aws_elasticache_replication_group.redis.primary_endpoint_address] # Obtener DNS del cluster Redis
}