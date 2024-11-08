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

# Importar el certificado a ACM con rutas definida en locals.tf
resource "aws_acm_certificate" "acm-certificate-lab04" {
  certificate_body = file(local.certificado_path)
  private_key      = file(local.privatekey_path)

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
  internal           = true
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

# Target group para el ALB interno con HTTPS
resource "aws_lb_target_group" "internal-alb-tg" {
  name        = "internal-alb-tg-lab04"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.vpc-main.id
  target_type = "instance"
  health_check {
    protocol = "HTTPS"
    port     = 443
    path     = "/health" # Ruta de health check personalizada
  }
  tags = {
    Name          = "internal-alb-tg-lab04"
    resource-type = "tg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Asociar el target group del ALB
# resource "aws_lb_target_group_attachment" "internal-alb-tg-attachment" {
#   depends_on       = [aws_lb_target_group_attachment.external-nlb-tg-attachment]
#   target_group_arn = aws_lb_target_group.internal-alb-tg.arn
#   target_id        = aws_lb.internal-alb.arn
#   port             = 443
# }

# Crear un NLB como load balancer externo
resource "aws_lb" "external-nlb" {
  name               = "external-nlb-lab04"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb-sg.id]
  subnet_mapping {
    subnet_id = aws_subnet.public-subnet-1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.public-subnet-2.id
  }
  tags = {
    Name          = "external-nlb-lab04"
    resource-type = "nlb"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Target group para el NLB
resource "aws_lb_target_group" "external-nlb-tg" {
  name        = "external-nlb-tg-lab04"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc-main.id
  target_type = "alb"
  health_check {
    protocol = "HTTPS"
    port     = 443
  }
  tags = {
    Name          = "external-nlb-tg-lab04"
    resource-type = "tg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Asociar el target group del NLB
resource "aws_lb_target_group_attachment" "external-nlb-tg-attachment" {
  # Forzar dependencia explícita para evitar error al crearse antes que el listener del ALB
  depends_on = [
    aws_lb.internal-alb,
    aws_lb_listener.listener-internal-alb-https
  ]
  target_group_arn = aws_lb_target_group.external-nlb-tg.arn
  target_id        = aws_lb.internal-alb.arn
}

# Listener para el tráfico HTTPS en el NLB
resource "aws_lb_listener" "listener-external-nlb-https" {
  load_balancer_arn = aws_lb.external-nlb.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-nlb-tg.arn
  }
}


/*=========================================
=                  EFS                    =
=========================================*/

# Crear un sistema de archivos EFS para almacenamiento compartido
resource "aws_efs_file_system" "efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # Tiempo de transicion a almacenamiento infrecuente (IA) en dias
  }
  tags = {
    Name          = "efs-lab04"
    resource-type = "efs"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear mount targets de EFS en cada subred privada

# Subred privada 1
resource "aws_efs_mount_target" "efs-mount-target-1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.efs-sg.id]
}

#Subred privada 2
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
# Obtener informacion de la cuenta autenticada para usarla en la policy de acceso al bucket de manera dinamica
data "aws_caller_identity" "current" {}

# Crear policy de acceso dinamica para el bucket:
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
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cf-distribution.arn}" # Solo podra acceder si el ARN es el de la distribucion de Cloudfront de este codigo
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-instance-role-lab04" # Acceso para rol de instancias creadas en cualquier cuenta desde este codigo
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

# Crear una distribución de Cloudfront

resource "aws_cloudfront_distribution" "cf-distribution" {
  origin {
    domain_name = aws_lb.external-nlb.dns_name
    origin_id   = "nlb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"           # Asegura que el trafico vaya a HTTPS en el ALB
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"] # Especifica los protocolos SSL permitidos para la conexion con el ALB
    }
  }

  # Configuración de los comportamientos de la caché
  default_cache_behavior {
    #cache_policy_id = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    target_origin_id       = "nlb-origin"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    # Cacheo de la respuesta
    min_ttl     = 0
    default_ttl = 3600  # 1 hora
    max_ttl     = 86400 # 1 dia
  }

  # Sin restriccion por localizacion geografica
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Configuración del certificado SSL
  viewer_certificate {
    #acm_certificate_arn = aws_acm_certificate.acm-certificate-lab04.arn # Certificado SSL
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }

  # Activar, descripcion y root al que accede
  enabled             = true
  comment             = "Cloudfront distribution hacia NLB"
  default_root_object = "index.php"
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
  name = "db-secret-lab04-28"
  #kms_key_id  = aws_kms_key.kms-key.id   # Inutilizada para usar la KMS key con la que se cifro la RDS de la snapshot y asi no perder la configuracion de WP entre cuentas
  kms_key_id  = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135" # KMS key con la que se cifro la RDS de la snapshot
  description = "Credenciales para la base de datos"

  tags = {
    Name          = "db-secret-lab04-28"
    resource-type = "secretsmanager"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear version de secreto con las credenciales de la base de datos
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
  depends_on                          = [aws_iam_role.rds-monitoring]
  identifier                          = "rds-lab04"
  instance_class                      = var.rds-type
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]
  db_subnet_group_name                = aws_db_subnet_group.rds-subnet-group.name
  iam_database_authentication_enabled = true
  deletion_protection                 = false
  multi_az                            = true
  skip_final_snapshot                 = true
  snapshot_identifier                 = "rds-acf-lab04"

  # Parametros no utilizados al usar una snapshot como origen
  # engine                              = "postgres"
  # allocated_storage                   = 20
  # username                            = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["username"]
  # password                            = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["password"]
  # db_name                             = "wp_db"
  # backup_retention_period             = 7

  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Usar la clave KMS para cifrado de datos en la instancia RDS
  #kms_key_id        = aws_kms_key.kms-key.arn
  kms_key_id        = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135" # KMS key con la que se cifro la RDS de la snapshot
  storage_encrypted = true

  tags = {
    #Name         = "rds-lab04"
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

# Crear réplica de lectura para RDS
resource "aws_db_instance" "rds-replica" {
  replicate_source_db                 = aws_db_instance.rds.identifier
  iam_database_authentication_enabled = true
  publicly_accessible                 = false
  auto_minor_version_upgrade          = false
  backup_retention_period             = 7
  identifier                          = "rds-replica-lab04"
  instance_class                      = var.rds-type
  multi_az                            = false
  skip_final_snapshot                 = true
  # kms_key_id                        = aws_kms_key.kms-key.arn
  kms_key_id        = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135" # KMS key con la que se cifro la RDS de la snapshot
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
=           Auto Scaling Group            =
=========================================*/

# Crear un template a partir de un archivo user_data.sh en el root del proyecto
# data "template_file" "user_data" {
#   template = file("${path.root}/user_data.sh")
# }

# Crear un launch template para el auto scaling group
resource "aws_launch_template" "lt-lab04" {
  image_id               = var.ami-id
  instance_type          = var.ec2-type
  vpc_security_group_ids = [aws_security_group.instancias-sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-instance-profile.name # Asociar el perfil de instancia definido en iam.tf al launch template
  }
  user_data = base64encode(<<-EOF
#!/bin/bash
yum install -y amazon-efs-utils
mount -t efs -o tls ${aws_efs_file_system.efs.id}:/ /mnt
echo "${aws_efs_file_system.efs.id}:/ /mnt efs _netdev,tls 0 0" >> /etc/fstab
ln -s /mnt /var/www/html
cat <<'EOL' > /etc/httpd/conf.d/ssl.conf
<VirtualHost *:443>

    DocumentRoot /var/www/html
    ServerName ${aws_lb.external-nlb.dns_name}

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
cat <<-'EOV' > /var/www/html/wp-config.php
<?php

require 'vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;
use Aws\Exception\AwsException;

$client = new SecretsManagerClient([
    'version' => 'latest',
    'region'  => 'us-east-1'
    ]);

$result = $client->getSecretValue([
    'SecretId' => '${aws_secretsmanager_secret.db-secret.arn}',  // Nombre del secreto generado de manera dinamica
]);

$secret = json_decode($result['SecretString'], true);

$username = $secret['username'];
$password = $secret['password'];

define( 'AS3CF_SETTINGS', serialize( array(
    'provider' => 'aws',
    'use-server-roles' => true,
) ) );
define( 'DB_NAME', 'wp_db' );
define( 'DB_USER', $username );
define( 'DB_PASSWORD', $password );
define( 'DB_HOST', '${aws_route53_record.rds-record.name}'  );  // Nombre del registro DNS interno de RDS generado de manera dinamica
define('WP_SITEURL', 'https://' . $_SERVER['HTTP_HOST']);
define('WP_HOME', 'https://' . $_SERVER['HTTP_HOST']);
define('WP_CACHE',true);
define('WP_REDIS_HOST', '${aws_route53_record.redis-record.name}'); // Nombre del registro DNS interno de Redis generado de manera dinamica
define('WP_REDIS_PORT', 6379);
define('MEMCACHED_HOST', '${aws_route53_record.memcached-record.name}');  // Nombre del registro DNS interno de Memcached generado de manera dinamica
define('MEMCACHED_PORT', 11211);
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AS3CF_ASSETS_PULL_SETTINGS', serialize( array(
    'domain' => '${aws_cloudfront_distribution.cf-distribution.domain_name}',
    'rewrite-urls' => true,
    'force-https' => true,
    'serve-from-s3' => true,
    'ssl' => 'https',
    'expires' => 365,
) ) );
$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */


/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOV
systemctl restart httpd
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      resource_type = "ec2"
      env           = "lab04"
      owner         = "alvarocf"
    }
  }
}

# Crear un auto scaling group para las instancias EC2
resource "aws_autoscaling_group" "asg" {
  name = "asg-lab04"
  launch_template {
    id      = aws_launch_template.lt-lab04.id
    version = "$Latest"
  }
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 3
  vpc_zone_identifier       = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
  target_group_arns         = [aws_lb_target_group.internal-alb-tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = "ec2-lab04"
    propagate_at_launch = true
  }
}

# Crear una policy para el auto scaling group
resource "aws_autoscaling_policy" "asg-policy" {
  name                   = "asg-policy-lab04"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Crear un cloudwatch alarm para el auto scaling group basado en el uso de CPU que activa la policy creada anteriormente
resource "aws_cloudwatch_metric_alarm" "asg-alarm" {
  alarm_name          = "asg-alarm-lab04"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 75

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Monitorizacion de la CPU de EC2"
  alarm_actions     = [aws_autoscaling_policy.asg-policy.arn]
  tags = {
    Name  = "asg-alarm-lab04"
    env   = "lab04"
    owner = "alvarocf"
  }
}