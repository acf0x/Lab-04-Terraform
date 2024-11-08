/*=========================================
=                  ACM                    =
=========================================*/

/* Importar un certificado SSL a AWS Certificate Manager (ACM) 
   Utilizado para asegurar la comunicación HTTPS en los recursos configurados */

resource "aws_acm_certificate" "acm-certificate-lab04" {
  certificate_body = file(local.certificado_path) # Ruta del archivo de certificado definida en locals.tf
  private_key      = file(local.privatekey_path)  # Ruta de la llave privada asociada definida en locals.tf

  tags = {
    Name          = "acm-certificate-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "acm"
  }
}