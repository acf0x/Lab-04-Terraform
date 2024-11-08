# Variable de seleccion de region en AWS
variable "aws_region" {
  description = "La region de AWS"
  default     = "us-east-1"
}

# Variables de autenticacion de AWS
variable "aws_access_key" {
  description = "access_key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "secret_key"
  type        = string
  sensitive   = true
}

# Variables para la ruta del certificado y clave privada para HTTPS
variable "certificado" {
  description = "Ruta al archivo del certificado"
  type        = string
  default     = "C:/Users/casfe/my-certificate.pem"
}

variable "private-key" {
  description = "Ruta al archivo de la clave privada"
  type        = string
  default     = "C:/Users/casfe/my-private-key.pem"
}

variable "ami-id" {
  description = "Variable para la imagen de AMI"
  #default    = "ami-06b21ccaeff8cd686"   # AMI original amazon linux 2023 en us-east-1
  default = "ami-0f119086802ffd967" # AMI con SSL end to end, composer+aws sdk, memcached para sesiones, plugins de redis y s3 para wp
}

variable "ec2-type" {
  description = "Variable para el tipo de instancia de EC2"
  default     = "t2.micro"
}

variable "rds-type" {
  description = "Variable para el tipo de instancia de RDS"
  default     = "db.t4g.micro"
}

variable "cache-type" {
  description = "Variable para el tipo de instancia de cache"
  default     = "cache.t3.micro"
}