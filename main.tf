/*=========================================
=             VPC Configuration           =
=========================================*/

# Crear vpc principal
resource "aws_vpc" "vpc-main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name          = "vpc-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear internet gateway
resource "aws_internet_gateway" "igw-main" {
  vpc_id = aws_vpc.vpc-main.id
  tags = {
    Name          = "IGW-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear subred pública 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc-main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name          = "public-subnet-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear subred pública 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.vpc-main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name          = "public-subnet-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear subred privada 1
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.vpc-main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name          = "private-subnet-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear subred privada 2
resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.vpc-main.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  tags = {
    Name          = "private-subnet-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear elastic ip 1 para NAT gateway 1
resource "aws_eip" "eip-1" {
  tags = {
    Name          = "EIP-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear elastic ip 2 para NAT gateway 2
resource "aws_eip" "eip-2" {
  tags = {
    Name          = "EIP-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear NAT gateway 1 en subnet publica 1
resource "aws_nat_gateway" "natgw-1" {
  subnet_id     = aws_subnet.public-subnet-1.id
  allocation_id = aws_eip.eip-1.id
  tags = {
    Name          = "natgw-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear NAT gateway 2 en subnet publica 2
resource "aws_nat_gateway" "natgw-2" {
  subnet_id     = aws_subnet.public-subnet-2.id
  allocation_id = aws_eip.eip-2.id
  tags = {
    Name          = "natgw-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear tabla de rutas para subredes públicas
resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-main.id
  }
  tags = {
    Name          = "rtb-public-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear tabla de rutas para subred privada 1
resource "aws_route_table" "rtb-private-1" {
  vpc_id = aws_vpc.vpc-main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw-1.id
  }
  tags = {
    Name          = "rtb-private-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear tabla de rutas para subred privada 2
resource "aws_route_table" "rtb-private-2" {
  vpc_id = aws_vpc.vpc-main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw-2.id
  }
  tags = {
    Name          = "rbt-private-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Asociar subred pública 1 con la tabla de rutas pública
resource "aws_route_table_association" "rtb-asoc-public-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.rtb-public.id
}

# Asociar subred pública 2 con la tabla de rutas pública
resource "aws_route_table_association" "rtb-asoc-public-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.rtb-public.id
}

# Asociar subred privada 1 con la tabla de rutas privada 1
resource "aws_route_table_association" "rtb-asoc-private-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.rtb-private-1.id
}

# Asociar subred privada 2 con la tabla de rutas privada 2
resource "aws_route_table_association" "rtb-asoc-private-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.rtb-private-2.id
}

# Crear VPC para backups
resource "aws_vpc" "vpc-backup" {
  cidr_block           = "192.168.0.0/24"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name          = "vpc-backup-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# VPC Peering entre vpc-main y vpc-backup
resource "aws_vpc_peering_connection" "vpc-peering-main-backup" {
  vpc_id      = aws_vpc.vpc-main.id
  peer_vpc_id = aws_vpc.vpc-backup.id
  auto_accept = true

  tags = {
    Name          = "vpc-peering-main-backup-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear subred privada 1 en vpc-backup
resource "aws_subnet" "private-subnet-backup-1" {
  vpc_id                  = aws_vpc.vpc-backup.id
  cidr_block              = "192.168.0.0/28"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = {
    Name          = "private-subnet-backup-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear subred privada 2 en vpc-backup
resource "aws_subnet" "private-subnet-backup-2" {
  vpc_id                  = aws_vpc.vpc-backup.id
  cidr_block              = "192.168.0.16/28"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = false
  tags = {
    Name          = "private-subnet-backup-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Ruta en tabla de rutas pública (rtb-public) hacia vpc-backup
resource "aws_route" "public_to_backup" {
  route_table_id            = aws_route_table.rtb-public.id
  destination_cidr_block    = "192.168.0.0/24" # CIDR de vpc-backup
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id
}

# Ruta en tabla de rutas privada 1 (rtb-private-1) hacia vpc-backup
resource "aws_route" "private_1_to_backup" {
  route_table_id            = aws_route_table.rtb-private-1.id
  destination_cidr_block    = "192.168.0.0/24" # CIDR de vpc-backup
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id
}

# Ruta en tabla de rutas privada 2 (rtb-private-2) hacia vpc-backup
resource "aws_route" "private_2_to_backup" {
  route_table_id            = aws_route_table.rtb-private-2.id
  destination_cidr_block    = "192.168.0.0/24" # CIDR de vpc-backup
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id
}

# Crear una tabla de rutas en vpc-backup
resource "aws_route_table" "rtb-backup" {
  vpc_id = aws_vpc.vpc-backup.id
  route {
    cidr_block                = "10.0.0.0/16" # CIDR de vpc-main
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id
  }
  tags = {
    Name          = "rtb-backup-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Asociar la tabla de rutas con la subred privada 1 de vpc-backup
resource "aws_route_table_association" "rtb-backup-association-1" {
  subnet_id      = aws_subnet.private-subnet-backup-1.id
  route_table_id = aws_route_table.rtb-backup.id
}

# Asociar la tabla de rutas con la subred privada 2 de vpc-backup
resource "aws_route_table_association" "rtb-backup-association-2" {
  subnet_id      = aws_subnet.private-subnet-backup-2.id
  route_table_id = aws_route_table.rtb-backup.id
}


/*=========================================
=                 ACM                     =
=========================================*/

# Importar el certificado a ACM
resource "aws_acm_certificate" "acm-certificate-lab04" {
  certificate_body = file(var.certificado)
  private_key      = file(var.private-key)

  tags = {
    Name          = "acm-certificate-lab04"
    resource-type = "acm"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/*=========================================
=              Load balancers             =
=========================================*/

# Crear un ALB como load balancer interno
resource "aws_lb" "internal-alb" {
  name               = "alb-lab04"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  tags = {
    Name          = "alb-lab04"
    resource-type = "alb"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Listener para el tráfico HTTPS en el ALB interno
resource "aws_lb_listener" "listener-internal-alb-https" {
  load_balancer_arn = aws_lb.internal-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm-certificate-lab04.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-alb-tg.arn
  }
}

# Target group para el ALB interno con HTTP
resource "aws_lb_target_group" "internal-alb-tg" {
  name        = "internal-alb-tg-lab04"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.vpc-main.id
  target_type = "instance"
  health_check {
    protocol = "HTTPS"
    port     = 443
    path     = "/health"
  }
  tags = {
    Name          = "internal-alb-tg-lab04"
    resource-type = "tg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Asociar el target group del ALB
resource "aws_lb_target_group_attachment" "internal-alb-tg-attachment" {
  #  depends_on       = [aws_lb_target_group_attachment.external-nlb-tg-attachment]
  target_group_arn = aws_lb_target_group.internal-alb-tg.arn
  target_id        = aws_instance.ec2-test-6.id
  port             = 443
}

# # Crear un NLB como load balancer externo
# resource "aws_lb" "external-nlb" {
#   name               = "external-nlb-lab04"
#   internal           = false
#   load_balancer_type = "network"
#   security_groups    = [aws_security_group.nlb-sg.id]
#   subnet_mapping {
#     subnet_id = aws_subnet.public-subnet-1.id
#   }
#   subnet_mapping {
#     subnet_id = aws_subnet.public-subnet-2.id
#   }
#   tags = {
#     Name          = "external-nlb-lab04"
#     resource-type = "nlb"
#     env           = "lab04"
#     owner         = "alvarocf"
#   }
# }

# # Target group para el NLB
# resource "aws_lb_target_group" "external-nlb-tg" {
#   name        = "external-nlb-tg-lab04"
#   port        = 443
#   protocol    = "TCP"
#   vpc_id      = aws_vpc.vpc-main.id
#   target_type = "alb"
#   health_check {
#     protocol = "HTTP"
#     port     = 80
#   }
#   tags = {
#     Name          = "external-nlb-tg-lab04"
#     resource-type = "tg"
#     env           = "lab04"
#     owner         = "alvarocf"
#   }
# }

# # Asociar el target group del NLB
# resource "aws_lb_target_group_attachment" "external-nlb-tg-attachment" {
#   # Forzar dependencia explícita para evitar error al crearse antes que el listener del ALB
#   depends_on = [
#     aws_lb.internal-alb,
#     aws_lb_listener.listener-internal-alb-https
#   ]
#   target_group_arn = aws_lb_target_group.external-nlb-tg.arn
#   target_id        = aws_lb.internal-alb.arn
# }

# # Listener para el tráfico HTTPS en el NLB
# resource "aws_lb_listener" "listener-external-nlb-https" {
#   load_balancer_arn = aws_lb.external-nlb.arn
#   port              = 443
#   protocol          = "TCP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.external-nlb-tg.arn
#   }
# }


/*=========================================
=                  EFS                    =
=========================================*/

# Crear un sistema de archivos EFS para almacenamiento compartido
resource "aws_efs_file_system" "efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name          = "efs-lab04"
    resource-type = "efs"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear mount targets de EFS en cada subred privada
resource "aws_efs_mount_target" "efs-mount-target-1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "efs-mount-target-2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-subnet-2.id
  security_groups = [aws_security_group.efs-sg.id]
}

/*=========================================
=                  S3                     =
=========================================*/

# Crear un bucket de S3 para almacenamiento de archivos estáticos
resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-lab04"
  tags = {
    Name          = "bucket-lab04"
    resource-type = "s3"
    env           = "test"
    owner         = "alvarocf"
  }
}

# Habilitar el versioning en el bucket de S3
resource "aws_s3_bucket_versioning" "bucket-versioning-ejercicio" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configurar el bloqueo de acceso público al bucket de S3
resource "aws_s3_bucket_public_access_block" "s3-public-access-block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Obtener información de la cuenta autenticada para usarla en la policy de acceso al bucket
data "aws_caller_identity" "current" {}

# Crear policy de acceso para el bucket:
resource "aws_s3_bucket_policy" "s3-policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cf-distribution.arn}"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-instance-role-lab04"
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

/*=========================================
=               CloudFront                =
=========================================*/

# Crear una distribución de CloudFront para el bucket S3
resource "aws_cloudfront_distribution" "cf-distribution" {
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin-access-control.id

  }
  enabled = true
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.bucket.id
    #  cache_policy_id = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Crear un OAC para CloudFront que apunte al bucket S3
resource "aws_cloudfront_origin_access_control" "origin-access-control" {
  name                              = "origin-access-control-lab04"
  description                       = "OAC para CloudFront que apunta al bucket S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}


/*=========================================
=          KMS y Secrets Manager          =
=========================================*/

# Crear clave de KMS para cifrar los secretos
resource "aws_kms_key" "kms-key" {
  description             = "KMS para encriptar secretos"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name          = "kms-key-lab04"
    resource-type = "kms"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear alias para usar clave KMS en Secrets Manager
resource "aws_kms_alias" "db-kms-alias" {
  name          = "alias/db-kms-alias-lab04"
  target_key_id = aws_kms_key.kms-key.id
}

# Guardar credenciales de la base de datos en Secrets Manager
resource "aws_secretsmanager_secret" "db-secret" {
  name = "db-secret-lab04-26"
  #kms_key_id  = aws_kms_key.kms-key.id
  kms_key_id  = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135"
  description = "Credenciales para la base de datos"

  tags = {
    Name          = "db-secret-lab04-26"
    resource-type = "secretsmanager"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

resource "aws_secretsmanager_secret_version" "db-secret-version" {
  secret_id = aws_secretsmanager_secret.db-secret.id
  secret_string = jsonencode({
    username = "wpadmin"
    password = "wpadmin123"
  })
}

/*=========================================
=                  RDS                    =
=========================================*/

# Crear un grupo de subredes en vpc-main para RDS
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group-lab04"
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  tags = {
    Name          = "rds-subnet-group-lab04"
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear un grupo de subredes en vpc-backup para RDS backup
resource "aws_db_subnet_group" "rds-backup-subnet-group" {
  name       = "rds-backup-subnet-group-lab04"
  subnet_ids = [aws_subnet.private-subnet-backup-1.id, aws_subnet.private-subnet-backup-2.id]

  tags = {
    Name          = "rds-subnet-group-lab04"
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear instancia RDS
resource "aws_db_instance" "rds" {
  identifier = "rds-lab04"
  #engine                              = "postgres"
  instance_class = "db.t4g.micro"
  #allocated_storage                   = 20
  #username                            = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["username"]
  #password                            = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["password"]
  #db_name                             = "wp_db"
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]
  db_subnet_group_name                = aws_db_subnet_group.rds-subnet-group.name
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  deletion_protection                 = false
  multi_az                            = true
  skip_final_snapshot                 = true
  #backup_retention_period             = 7
  snapshot_identifier = "rds-acf-lab04"

  # Usar la clave KMS para cifrado de datos en la instancia RDS
  #kms_key_id        = aws_kms_key.kms-key.arn
  kms_key_id        = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135"
  storage_encrypted = true

  tags = {
    #Name          = "rds-lab04"
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear réplica de lectura para RDS
resource "aws_db_instance" "rds-replica" {
  replicate_source_db = aws_db_instance.rds.identifier
  #replica_mode               = "mounted"
  iam_database_authentication_enabled = true
  publicly_accessible                 = false
  auto_minor_version_upgrade          = false
  backup_retention_period             = 7
  identifier                          = "rds-replica-lab04"
  instance_class                      = "db.t4g.micro"
  multi_az                            = false
  skip_final_snapshot                 = true
  #kms_key_id                 = aws_kms_key.kms-key.arn
  kms_key_id        = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135"
  storage_encrypted = true
  tags = {
    Name          = "rds-replica-lab04"
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}
/*
# Crear réplica de backup en vpc-backup
resource "aws_db_instance" "rds-backup-replica" {
  replicate_source_db        = aws_db_instance.rds.identifier
  #replica_mode               = "mounted"
  db_subnet_group_name       = aws_db_subnet_group.rds-backup-subnet-group.name
  vpc_security_group_ids     = [aws_security_group.rds-backup-sg.id]
  publicly_accessible        = false
  auto_minor_version_upgrade = false
  backup_retention_period    = 7
  identifier                 = "rds-backup-replica-lab04"
  instance_class             = "db.t4g.micro"
  multi_az                   = false
  skip_final_snapshot        = true
  kms_key_id                 = aws_kms_key.kms-key.arn
  storage_encrypted          = true
  tags = {
    Name          = "rds-backup-replica-lab04"
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}
*/

/*=========================================
=               ElastiCache               =
=========================================*/

# Subnet group para ElastiCache
resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
  name       = "elasticache-subnet-group-lab04"
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
  tags = {
    Name          = "elasticache-subnet-group-lab04"
    resource-type = "elasticache"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear Memcached para informacion de sesiones
resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "memcached-lab04"
  engine               = "memcached"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = aws_elasticache_subnet_group.elasticache-subnet-group.name
  security_group_ids   = [aws_security_group.memcached-sg.id]
  tags = {
    Name          = "memcached-lab04"
    resource-type = "elasticache"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear cluster Redis para almacenamiento de cache general con HA y auto failover
resource "aws_elasticache_replication_group" "redis" {
  description                = "Cluster de Redis para cache general con HA"
  replication_group_id       = "redis"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 2
  multi_az_enabled           = true
  automatic_failover_enabled = true
  port                       = 6379
  security_group_ids         = [aws_security_group.redis-sg.id]
  subnet_group_name          = aws_elasticache_subnet_group.elasticache-subnet-group.name
  tags = {
    Name          = "redis-lab04"
    resource-type = "elasticache"
    env           = "lab04"
    owner         = "alvarocf"
  }
}


/*=========================================
=                Route 53                 =
=========================================*/

# Crear una zona en Route53
resource "aws_route53_zone" "route53-zone" {
  name = "acflab04.com"
  vpc {
    vpc_id = aws_vpc.vpc-main.id
  }
  tags = {
    Name          = "route53-zone-lab04"
    resource-type = "route53"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear un registro DNS para el ELB externo (NLB)
# resource "aws_route53_record" "nlb-record" {
#   zone_id = aws_route53_zone.route53-zone.zone_id
#   name    = "nlb.acflab04.com" # Subdominio para el NLB
#   type    = "A"
#   alias {
#     name                   = aws_lb.external-nlb.dns_name
#     zone_id                = aws_lb.external-nlb.zone_id
#     evaluate_target_health = true
#   }
# }

# Crear un registro DNS para el ELB interno (ALB)
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

# Crear un registro DNS para la instancia de RDS
resource "aws_route53_record" "rds-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "db.acflab04.com" # Subdominio para la instancia de RDS
  type    = "CNAME"
  ttl     = 300
  records = [split(":", aws_db_instance.rds.endpoint)[0]] # Obtener DNS de RDS sin el puerto
}

# Crear un registro DNS para Memcached
resource "aws_route53_record" "memcached-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "memcached.acflab04.com" # Subdominio para Memcached
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_cluster.memcached.configuration_endpoint]
}

# Crear un registro DNS para Redis
resource "aws_route53_record" "redis-record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "redis.acflab04.com" # Subdominio para Redis
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.redis.primary_endpoint_address]
}

/*=========================================
=              ECR y ECS                  =
=========================================*/

/*
# Crear un repositorio de ECR
resource "aws_ecr_repository" "ecr-repo" {
  name = "ecr-repo-lab04"

  tags = {
    Name          = "ecr-repo-lab04"
    resource-type = "ecr"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear un cluster ECS
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-cluster-lab04"

  tags = {
    Name          = "ecs-cluster-lab04"
    resource-type = "ecs"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear definicion de tarea ECS
resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "task-lab04"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc" # Modo de red para ECS en una VPC
  cpu                      = "256"
  memory                   = "512"
  task_role_arn = aws_iam_role.ecs-task-role.arn # Rol que permite al contenedor acceder a otros servicios AWS

  container_definitions = jsonencode([{
    name      = "ecs-container"
    image     = "${aws_ecr_repository.ecr-repo.repository_url}:latest"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      },
    ]
  }])

  # Almacenamiento que usarán los containers de la tarea
  volume {
    name = "service-storage"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.efs.id
      root_directory          = "/opt/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.efs_access.id
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    Name          = "task-lab04"
    resource-type = "ecs"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear servicio ECS
resource "aws_ecs_service" "ecs-service" {
  name            = "ecs-service-lab04"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.internal-alb-tg.arn
    container_name   = "ecs-container"
    container_port   = 80
  }

  tags = {
    Name          = "ecs-service-lab04"
    resource-type = "ecs"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

*/

# Crear una instancia de prueba
resource "aws_instance" "ec2-test-6" {
  ami                    = var.ami-id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.instancias-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-instance-profile.name
  user_data              = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mount -t efs -o tls ${aws_efs_file_system.efs.id}:/ /mnt/efs
              echo "${aws_efs_file_system.efs.id}:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
              ln -s /mnt/efs /var/www/html
              cat <<'EOL' > /etc/httpd/conf.d/ssl.conf
              <VirtualHost *:443>

                  DocumentRoot /var/www/html
                  ServerName ${aws_lb.internal-alb.dns_name}

                  SSLEngine on
                  SSLCertificateFile /etc/ssl/my-certificate.pem
                  SSLCertificateKeyFile /etc/ssl/my-private-key.pem

                  SSLProtocol all -SSLv2 -SSLv3
                  SSLCipherSuite HIGH:!aNULL:!MD5

                  <Directory /var/www/html>
                      AllowOverride All
                  </Directory>

              </VirtualHost>
              EOL
              systemctl restart httpd
              EOF
  tags = {
    Name          = "EC2-test-6"
    resource-type = "ec2"
    env           = "test"
    owner         = "alvarocf"
  }
}
