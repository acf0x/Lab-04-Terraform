/*=========================================
=          KMS y Secrets Manager          =
=========================================*/

/* Crear clave de KMS para cifrar los secretos 
   Permite el cifrado de datos sensibles en Secrets Manager */

resource "aws_kms_key" "kms-key" {
  description             = "KMS para encriptar secretos"
  deletion_window_in_days = 7    # Tiempo de espera para eliminación de clave
  enable_key_rotation     = true # Rotación automática de clave

  tags = {
    Name          = "kms-key-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "kms"
  }
}

/* Crear alias para la clave KMS 
   Facilita el acceso a la clave en otras configuraciones */

resource "aws_kms_alias" "db-kms-alias" {
  name          = "alias/db-kms-alias-lab04" # Alias de la clave
  target_key_id = aws_kms_key.kms-key.id     # ID de la clave KMS asociada
}

/* Guardar credenciales en Secrets Manager 
   Almacena las credenciales encriptadas de la base de datos */

resource "aws_secretsmanager_secret" "db-secret" {
  name = "acf-db-secret-lab04"
  # kms_key_id  = aws_kms_key.kms-key.id   # Inutilizada para usar la KMS key con la que se cifro la RDS de la snapshot y asi no perder la configuracion de WP entre cuentas
  kms_key_id  = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135" # ARN de la clave KMS
  description = "Credenciales para la base de datos"

  tags = {
    Name          = "acf-db-secret-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "secretsmanager"
  }
}

/* Crear version de secreto con las credenciales de base de datos 
   Define el contenido en formato JSON con las credenciales */

resource "aws_secretsmanager_secret_version" "db-secret-version" {
  secret_id = aws_secretsmanager_secret.db-secret.id
  secret_string = jsonencode({
    username = "wpadmin"    # Nombre de usuario para base de datos
    password = "wpadmin123" # Contraseña para base de datos
  })
}