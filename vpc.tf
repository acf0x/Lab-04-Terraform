/*=========================================
=             VPC Configuration           =
=========================================*/

/* Crear VPC principal */

resource "aws_vpc" "vpc-main" {
  cidr_block           = "10.0.0.0/16" # CIDR para la VPC
  enable_dns_hostnames = true          # Habilitar resolucion DNS para hosts
  enable_dns_support   = true          # Habilitar soporte de DNS
  instance_tenancy     = "default"     # Tipo de tenencia de instancias (por defecto es compartida)

  tags = {
    Name          = "vpc-lab04" # Nombre de la VPC
    env           = "lab04"     # Entorno del recurso
    owner         = "alvarocf"  # Propietario del recurso
    resource-type = "vpc"       # Tipo de recurso
  }
}

/* Crear Internet Gateway */

resource "aws_internet_gateway" "igw-main" {
  vpc_id = aws_vpc.vpc-main.id # Asocia el IGW a la VPC creada anteriormente

  tags = {
    Name          = "IGW-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Crear Subredes Publicas */

/* Subred Publica 1 */

resource "aws_subnet" "public-subnet-1" {
  availability_zone       = "us-east-1a"        # Zona de disponibilidad para la subred
  cidr_block              = "10.0.1.0/24"       # Rango CIDR para la subred publica
  map_public_ip_on_launch = true                # Mapear IP publica a recursos lanzados en esta subred
  vpc_id                  = aws_vpc.vpc-main.id # Asociar la subred a la VPC

  tags = {
    Name          = "public-subnet-1-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Subred Publica 2 */

resource "aws_subnet" "public-subnet-2" {
  availability_zone       = "us-east-1b"        # Zona de disponibilidad para la subred
  cidr_block              = "10.0.2.0/24"       # Rango CIDR para la subred publica
  map_public_ip_on_launch = true                # Asignar IP publica a instancias lanzadas en esta subred
  vpc_id                  = aws_vpc.vpc-main.id # Asociar la subred a la VPC

  tags = {
    Name          = "public-subnet-2-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Crear Subredes Privadas */

/* Subred Privada 1 */

resource "aws_subnet" "private-subnet-1" {
  availability_zone       = "us-east-1a"        # Zona de disponibilidad para la subred
  cidr_block              = "10.0.3.0/24"       # Rango CIDR para la subred privada
  map_public_ip_on_launch = false               # No asignar IP publica a las instancias lanzadas en esta subred
  vpc_id                  = aws_vpc.vpc-main.id # Asociar la subred a la VPC

  tags = {
    Name          = "private-subnet-1-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Subred Privada 2 */

resource "aws_subnet" "private-subnet-2" {
  availability_zone       = "us-east-1b"        # Zona de disponibilidad para la subred
  cidr_block              = "10.0.4.0/24"       # Rango CIDR para la subred privada
  map_public_ip_on_launch = false               # No asignar IP publica a las instancias lanzadas en esta subred
  vpc_id                  = aws_vpc.vpc-main.id # Asociar la subred a la VPC

  tags = {
    Name          = "private-subnet-2-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Crear Elastic IPs para NAT Gateways */

/* Elastic IP 1 */

resource "aws_eip" "eip-1" {
  tags = {
    Name          = "eip-1-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Elastic IP 2 */

resource "aws_eip" "eip-2" {
  tags = {
    Name          = "eip-2-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Crear NAT Gateways */

/* NAT Gateway 1 */

resource "aws_nat_gateway" "natgw-1" {
  allocation_id = aws_eip.eip-1.id              # Asociar Elastic IP al NAT Gateway
  subnet_id     = aws_subnet.public-subnet-1.id # Asociar NAT Gateway a la subred publica 1

  tags = {
    Name          = "natgw-1-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* NAT Gateway 1 */

resource "aws_nat_gateway" "natgw-2" {
  allocation_id = aws_eip.eip-2.id              # Asociar Elastic IP al NAT Gateway
  subnet_id     = aws_subnet.public-subnet-2.id # Asociar NAT Gateway a la subred publica 2

  tags = {
    Name          = "natgw-2-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Configuración de Tablas de Rutas */

/* Tabla de Rutas Publica */
resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc-main.id # Asociar la tabla de rutas a la VPC

  route {
    cidr_block = "0.0.0.0/0"                      # Ruta a Internet
    gateway_id = aws_internet_gateway.igw-main.id # Asociar la ruta a Internet Gateway
  }

  tags = {
    Name          = "rtb-public-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Tabla de Rutas Privada 1 */

resource "aws_route_table" "rtb-private-1" {
  vpc_id = aws_vpc.vpc-main.id # Asociar la tabla de rutas a la VPC

  route {
    cidr_block     = "0.0.0.0/0"                # Ruta a Internet
    nat_gateway_id = aws_nat_gateway.natgw-1.id # Asociar la ruta a NAT Gateway 1
  }

  tags = {
    Name          = "rtb-private-1-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Tabla de Rutas Privada 2 */

resource "aws_route_table" "rtb-private-2" {
  vpc_id = aws_vpc.vpc-main.id # Asociar la tabla de rutas a la VPC

  route {
    cidr_block     = "0.0.0.0/0"                # Ruta a Internet
    nat_gateway_id = aws_nat_gateway.natgw-2.id # Asociar la ruta a NAT Gateway 2
  }

  tags = {
    Name          = "rbt-private-2-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "vpc"
  }
}

/* Asociaciones de Tablas de Rutas */

resource "aws_route_table_association" "rtb-asoc-public-1" {
  subnet_id      = aws_subnet.public-subnet-1.id # Subred Publica 1
  route_table_id = aws_route_table.rtb-public.id # Tabla de Rutas Publica
}

resource "aws_route_table_association" "rtb-asoc-public-2" {
  subnet_id      = aws_subnet.public-subnet-2.id # Subred Publica 2
  route_table_id = aws_route_table.rtb-public.id # Tabla de Rutas Publica
}

resource "aws_route_table_association" "rtb-asoc-private-1" {
  subnet_id      = aws_subnet.private-subnet-1.id   # Subred Privada 1
  route_table_id = aws_route_table.rtb-private-1.id # Tabla de Rutas Privada 1
}

resource "aws_route_table_association" "rtb-asoc-private-2" {
  subnet_id      = aws_subnet.private-subnet-2.id   # Subred Privada 2
  route_table_id = aws_route_table.rtb-private-2.id # Tabla de Rutas Privada 2
}