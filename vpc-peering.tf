/*=========================================
=              VPC Peering                =
=========================================*/

/* Crear VPC para backups */

resource "aws_vpc" "vpc-backup" {
  cidr_block           = "192.168.0.0/24" # CIDR para la VPC de backups
  enable_dns_hostnames = true             # Habilitar resolucion DNS para hosts
  enable_dns_support   = true             # Habilitar soporte DNS
  instance_tenancy     = "default"        # Tipo de tenencia de instancias (por defecto es compartida)

  tags = {
    Name          = "vpc-backup-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* VPC Peering entre VPC principal y VPC de backups */

resource "aws_vpc_peering_connection" "vpc-peering-main-backup" {
  vpc_id      = aws_vpc.vpc-main.id   # ID de la VPC principal
  peer_vpc_id = aws_vpc.vpc-backup.id # ID de la VPC de backups
  auto_accept = true                  # Aceptar la solicitud de peering automaticamente

  tags = {
    Name          = "vpc-peering-main-backup-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Crear subred privada 1 en VPC de backups */

resource "aws_subnet" "private-subnet-backup-1" {
  vpc_id                  = aws_vpc.vpc-backup.id # ID de la VPC de backups
  cidr_block              = "192.168.0.0/28"      # Rango CIDR para la subred privada 1 en VPC de backups
  availability_zone       = "us-east-1c"          # Zona de disponibilidad
  map_public_ip_on_launch = false                 # No asignar IP publica a las instancias lanzadas en esta subred
  tags = {
    Name          = "private-subnet-backup-1-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Crear subred privada 2 en VPC de backups */

resource "aws_subnet" "private-subnet-backup-2" {
  vpc_id                  = aws_vpc.vpc-backup.id # ID de la VPC de backups
  cidr_block              = "192.168.0.16/28"     # Rango CIDR para la subred privada 2 en VPC de backups
  availability_zone       = "us-east-1d"          # Zona de disponibilidad
  map_public_ip_on_launch = false                 # No asignar IP publica a las instancias lanzadas en esta subred
  tags = {
    Name          = "private-subnet-backup-2-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Ruta en tabla de rutas publica de VPC principal hacia VPC de backups */

resource "aws_route" "public-to-backup" {
  route_table_id            = aws_route_table.rtb-public.id # ID de la tabla de rutas publica
  destination_cidr_block    = "192.168.0.0/24"              # CIDR de destino (VPC de backups) 
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id
}

/* Ruta en tabla de rutas privada 1 de VPC principal hacia VPC de backups */

resource "aws_route" "private-1-to-backup" {
  route_table_id            = aws_route_table.rtb-private-1.id                      # ID de la tabla de rutas privada 1
  destination_cidr_block    = "192.168.0.0/24"                                      # CIDR de destino (VPC de backups)
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id # ID de la conexion de peering
}

/* Ruta en tabla de rutas privada 2 de VPC principal hacia VPC de backups */

resource "aws_route" "private-2-to-backup" {
  route_table_id            = aws_route_table.rtb-private-2.id                      # ID de la tabla de rutas privada 2
  destination_cidr_block    = "192.168.0.0/24"                                      # CIDR de destino (VPC de backups)
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id # ID de la conexion de peering
}

/* Crear una tabla de rutas en VPC de backups */

resource "aws_route_table" "rtb-backup" {
  vpc_id = aws_vpc.vpc-backup.id # ID de la VPC de backups
  route {
    cidr_block                = "10.0.0.0/16"                                         # CIDR de destino (VPC principal)
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-main-backup.id # ID de la conexion de peering
  }
  tags = {
    Name          = "rtb-backup-lab04"
    resource-type = "vpc"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Asociar la tabla de rutas con la subred privada 1 de VPC de backups */

resource "aws_route_table_association" "rtb-backup-association-1" {
  subnet_id      = aws_subnet.private-subnet-backup-1.id # ID de la subred privada 1 de VPC de backups
  route_table_id = aws_route_table.rtb-backup.id         # ID de la tabla de rutas de VPC de backups
}

/* Asociar la tabla de rutas con la subred privada 2 de VPC de backups */

resource "aws_route_table_association" "rtb-backup-association-2" {
  subnet_id      = aws_subnet.private-subnet-backup-2.id # ID de la subred privada 2 de VPC de backups
  route_table_id = aws_route_table.rtb-backup.id         # ID de la tabla de rutas de VPC de backups
}