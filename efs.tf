/*=========================================
=                  EFS                    =
=========================================*/

/* Crear un sistema de archivos EFS 
   Permite almacenamiento compartido entre varias instancias en la VPC */

resource "aws_efs_file_system" "efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # Política de transicion a Infrequent Access despues de 30 dias
  }

  tags = {
    Name          = "efs-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "efs"
  }
}

/* Montar EFS en subred privada 1 */

resource "aws_efs_mount_target" "efs-mount-target-1" {
  file_system_id  = aws_efs_file_system.efs.id     # ID del sistema de archivos EFS
  subnet_id       = aws_subnet.private-subnet-1.id # Subred donde se monta el EFS
  security_groups = [aws_security_group.efs-sg.id] # Grupo de seguridad para acceso a EFS
}

/* Montar EFS en subred privada 2 */

resource "aws_efs_mount_target" "efs-mount-target-2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-subnet-2.id
  security_groups = [aws_security_group.efs-sg.id]
}