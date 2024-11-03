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