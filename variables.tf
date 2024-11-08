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

variable "desired-capacity" {
  description = "Variable para la capacidad deseada de instancias en el grupo de autoscaling"
  default     = 2
}

variable "max-size" {
  description = "Variable para la capacidad maxima de instancias en el grupo de autoscaling"
  default     = 3
}

variable "min-size" {
  description = "Variable para la capacidad minima de instancias en el grupo de autoscaling"
  default     = 2
}

variable "scaling-adjustment" {
  description = "Variable para el ajuste de escalado en el grupo de autoscaling"
  default     = 1
}

variable "cw-treshold" {
  description = "Variable para el umbral de la alarma de CloudWatch."
  default     = 75
}

variable "num-cache-nodes-memcached" {
  description = "Variable para el numero de nodos en el cluster de Memcached."
  default     = 2
}

variable "num-cache-clusters-redis" {
  description = "Variable para el numero de clusters de Redis (minimo 2 para multi-az y auto failover)."
  default     = 2
}

variable "snapshot-identifier" {
  description = "Variable para el nombre de la snapshot de la RDS desde la que se restaura (privada). Su modificacion implica tener que configurar WordPress."
  default     = "rds-acf-lab04"
}

variable "kms-snapshot" {
  description = "Variable de KMS key (privada) con la que se cifro la RDS de la snapshot. Su modificacion implica no poder utilizar la configuracion almacenada en la snapshot."
  default     = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135"
}