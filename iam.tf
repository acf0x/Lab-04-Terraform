# Crear rol de IAM para las instancias EC2
resource "aws_iam_role" "ec2-instance-role" {
  name = "ec2-instance-role-lab04"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name          = "ec2-instance-role-lab04"
    env           = "lab04"
    resource-type = "iam"
    owner         = "alvarocf"
  }
}

# Adjuntar las politicas necesarias al rol de IAM
# Conectar por SSM
resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# Acceder a KMS
resource "aws_iam_role_policy_attachment" "kms-policy" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ROSAKMSProviderPolicy"
}
# Acceder a Secrets Manager
resource "aws_iam_role_policy_attachment" "secretsmanager-policy" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Crear un perfil de instancia para asociar el rol a la instancia EC2
resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "ec2-instance-profile-lab04"
  role = aws_iam_role.ec2-instance-role.name

  tags = {
    Name          = "ec2-instance-profile-lab04"
    env           = "lab04"
    resource-type = "iam-instance-profile"
    owner         = "alvarocf"
  }
}
