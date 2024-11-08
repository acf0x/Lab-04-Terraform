/*=========================================
=             Security Groups           =
=========================================*/

/* Grupo de seguridad para las instancias EC2 */

resource "aws_security_group" "instancias-sg" {
  name        = "instancias-sg-lab04"
  description = "Grupo de seguridad para las instancias"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir tráfico HTTPS desde cualquier direccion IP */
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id] # ID del grupo de seguridad del ALB
  }
  /* Egress rule para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "instancias-sg-lab04"
    resource-type = "sg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Grupo de seguridad para el balanceador de carga externo */

resource "aws_security_group" "nlb-sg" {
  name        = "nlb-sg-lab04"
  description = "Grupo de seguridad para el ELB externo (NLB)"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir trafico HTTPS desde cualquier IP */
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir trafico desde cualquier IP
  }
  /* Egress rule para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "nlb-sg-lab04"
    resource-type = "sg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Grupo de seguridad para el balanceador de carga interno */
resource "aws_security_group" "alb-sg" {
  name        = "internal-alb-sg-lab04"
  description = "Grupo de seguridad para el ELB interno (ALB)"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir trafico HTTPS desde el grupo de seguridad del NLB */
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb-sg.id] # ID del grupo de seguridad del NLB
  }
  /* Egress rule para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "alb-sg-lab04"
    resource-type = "sg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Grupo de seguridad para EFS */
resource "aws_security_group" "efs-sg" {
  name        = "efs-sg-lab04"
  description = "Grupo de seguridad para EFS"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir trafico NFS desde la VPC */
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc-main.cidr_block] # Permitir trafico solo desde la VPC principal
  }
  /* Egress rule para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "efs-sg-lab04"
    resource-type = "security-group"
    env           = "lab04"
    owner         = "alvarocf"
  }
}


/* Grupo de seguridad para RDS */
resource "aws_security_group" "rds-sg" {
  name        = "rds-sg-lab04"
  description = "Grupo de seguridad para RDS"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir trafico desde el grupo de seguridad de las instancias */
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.instancias-sg.id] # ID del grupo de seguridad de las instancias
  }
  /* Egress rules para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "rds-sg-lab04"
    resource-type = "sg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Grupo de seguridad para memcached */
resource "aws_security_group" "memcached-sg" {
  name        = "memcached-sg-lab04"
  description = "Grupo de seguridad para Memcached"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir trafico desde el grupo de seguridad de las instancias */
  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.instancias-sg.id] # ID del grupo de seguridad de las instancias
  }
  /* Egress rules para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "memcached-sg-lab04"
    resource-type = "sg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Grupo de seguridad para Redis */
resource "aws_security_group" "redis-sg" {
  name        = "redis-sg-lab04"
  description = "Grupo de seguridad para Redis"
  vpc_id      = aws_vpc.vpc-main.id # Asociar grupo de seguridad a la VPC principal

  /* Ingress rule para permitir trafico desde el grupo de seguridad de las instancias */
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.instancias-sg.id] # ID del grupo de seguridad de las instancias
  }
  /* Egress rules para permitir todo el trafico de salida */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "redis-sg-lab04"
    resource-type = "sg"
    env           = "lab04"
    owner         = "alvarocf"
  }
}
