***Plan/Checklist***

1. EC2 Funcionando 
2. Par de Claves SSH 
3. Docker Instalado 
4. AWS CLI Instalado 
5. AWS ECR Login
6. Archivo .env con las variables de entorno 
7. Docker compose
8. Loguearme con aws ecr 
9. docker compose up -d

***Comandos ciclo de vida Terraform***

1. terraform init

Inicializa el proyecto.
Descarga los plugins del proveedor (AWS, Azure, GCP) y prepara el entorno.

2. terraform plan

Muestra qué cambios se harán.
No ejecuta nada todavía, solo enseña el plan de acción (crear, cambiar o eliminar recursos).

3. terraform apply

Ejecuta el plan y crea o modifica los recursos en la nube.
Te pedirá confirmación antes de aplicarlo o utilizar --auto-approve para evitar confirmación manual.

4. terraform destroy

Elimina todos los recursos definidos en los archivos .tf.
Te pedirá confirmación antes de aplicarlo o utilizar --auto-approve para evitar confirmación manual.


5. terraform validate

Verifica que la sintaxis y configuración sean correctas sin ejecutar nada.

***Comandos cuando ya se están trabajndo los 3 entornos (dev, qa y prod)***

terraform -chdir=envs/dev init
terraform -chdir=envs/qa init
terraform -chdir=envs/prod init


Utilizar el mismo comando para hacer el apply:

terraform -chdir=envs/dev apply --auto-approve
terraform -chdir=envs/qa apply --auto-approve
terraform -chdir=envs/prod apply --auto-approve