# Crear un usuario IAM para el laboratorio
resource "aws_iam_user" "iam-lab05-terraform" {
  name = "user-terraform-lab05"
  tags = {
    "resource-type" = "IAM"
    "env"           = "lab05"
    "owner"         = "alvarocf"
  }
}

# Asignar politica de administrador al usuario IAM
resource "aws_iam_user_policy_attachment" "admin-policy" {
  user       = aws_iam_user.iam-lab05-terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Crear un access key para el usuario IAM
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.iam-lab05-terraform.name
}