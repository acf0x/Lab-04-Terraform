/*=========================================
=                  RDS                    =
=========================================*/

/* Crear un grupo de subredes en VPC principal para RDS 
   Agrupacion de subredes para la instancia RDS con alta disponibilidad */

resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group-lab04"
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id] # Subredes privadas en la VPC principal

  tags = {
    Name          = "rds-subnet-group-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "rds"
  }
}

/* Crear instancia RDS desde una snapshot 
   Utiliza la snapshot de una base de datos con WordPress configurado previamente 
   De esta forma, si se tiene acceso a esta snapshot, puede accederse directamente a WP tras ejecutar el codigo */

resource "aws_db_instance" "rds" {
  identifier                          = "rds-lab04"
  instance_class                      = var.rds-type                   # Tipo de instancia
  vpc_security_group_ids              = [aws_security_group.rds-sg.id] # Grupo de seguridad RDS
  db_subnet_group_name                = aws_db_subnet_group.rds-subnet-group.name
  iam_database_authentication_enabled = true            # Habilitar autenticacion IAM
  deletion_protection                 = false           # Proteccion contra eliminacion
  multi_az                            = true            # Alta disponibilidad
  skip_final_snapshot                 = true            # Omitir snapshot final
  snapshot_identifier                 = "rds-acf-lab04" # Snapshot origen de la instancia
  enabled_cloudwatch_logs_exports     = ["postgresql"]  # Exportacion de logs

  /* Parametros no utilizados al usar una snapshot como origen */
  # engine                              = "postgres"
  # allocated_storage                   = 20
  # username                            = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["username"]
  # password                            = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["password"]
  # db_name                             = "wp_db"
  # backup_retention_period             = 7
  # kms_key_id        = aws_kms_key.kms-key.arn

  kms_key_id        = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135" # KMS key con la que se cifro la RDS de la snapshot
  storage_encrypted = true                                                                          # Habilitar cifrado de almacenamiento

  tags = {
    resource-type = "rds"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Crear replica de lectura para RDS 
   Configura una replica de lectura que proporciona mayor rendimiento */

resource "aws_db_instance" "rds-replica" {
  replicate_source_db                 = aws_db_instance.rds.identifier # ID de la instancia principal
  iam_database_authentication_enabled = true
  publicly_accessible                 = false # Sin acceso publico
  auto_minor_version_upgrade          = false # No actualizar versiones menores
  backup_retention_period             = 7     # Dias de retencion de backups
  identifier                          = "rds-replica-lab04"
  instance_class                      = var.rds-type
  multi_az                            = false
  skip_final_snapshot                 = true

  kms_key_id        = "arn:aws:kms:us-east-1:314146321780:key/70baf81c-2132-4bbc-a394-35efed90b135" # KMS key con la que se cifro la RDS de la snapshot
  storage_encrypted = true

  tags = {
    Name          = "rds-replica-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "rds"
  }
}