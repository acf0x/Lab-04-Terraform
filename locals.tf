/* Directorio donde estan almacenados el certificado y clave privada
   path.cwd = raiz del proyecto */

locals {
  certificado_path = "${path.cwd}/my-certificate.pem"
  privatekey_path  = "${path.cwd}/my-private-key.pem"
}