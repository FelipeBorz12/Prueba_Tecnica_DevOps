# Guía Comparativa y Práctica: Terraform vs. AWS CloudFormation

Felipe, dominar e identificar las diferencias operativas entre **Terraform** y **CloudFormation** es una de las preguntas más comunes en las entrevistas DevOps para empresas que usan AWS. En esta guía analizaremos la teoría y prepararemos tu entorno local de Windows para que puedas desplegar infraestructura real en tu cuenta de AWS.

---

## 1. Tabla Comparativa Rápida

| Característica | Terraform | AWS CloudFormation |
| :--- | :--- | :--- |
| **Creador** | HashiCorp | AWS (Amazon Web Services) |
| **Soporte Cloud** | Multi-cloud (AWS, Azure, GCP, Kubernetes, Cloudflare, etc.) | Exclusivo de AWS (soporta recursos de terceros con extensiones, pero es complejo) |
| **Lenguaje** | **HCL** (HashiCorp Configuration Language) - Declarativo y legible | **YAML** o **JSON** - Declarativo pero más verboso |
| **Gestión de Estado** | Requiere un archivo de estado (`terraform.tfstate`) almacenado localmente o en un backend remoto (S3 + DynamoDB) | Administrado automáticamente por AWS (no existe archivo de estado local; el estado reside en el servicio de CloudFormation en la nube) |
| **Unidad de Gestión** | Directorio con archivos `.tf` | Plantilla única (Template) que se despliega como un **Stack** (Pila) |
| **Drift Detection** | Se ejecuta mediante `terraform plan` o `terraform refresh` comparando el estado actual con el código | Tiene una característica nativa llamada "Detect Drift" que compara el stack desplegado con su plantilla original en la consola |
| **Destrucción** | `terraform destroy` (destruye lo definido en el directorio) | Borrar el Stack desde la consola o CLI (elimina todos los recursos asociados a la plantilla) |

---

## 2. Preparación del Entorno en Windows

Para hacer las pruebas prácticas en tu cuenta de AWS, necesitas instalar las herramientas en tu máquina. Abre **PowerShell** como Administrador y ejecuta los siguientes comandos de instalación recomendados:

### Paso A: Instalar AWS CLI y Terraform CLI
En Windows 10/11, puedes instalar ambos fácilmente usando `winget`:

```powershell
# Instalar AWS CLI
winget install Amazon.AWSCLI

# Instalar Terraform CLI (distribuido por HashiCorp)
winget install Hashicorp.Terraform
```
*Nota: Después de instalarlos, debes cerrar y volver a abrir la terminal de PowerShell para que los comandos se carguen en el `PATH`.*

### Paso B: Validar Instalación
```powershell
aws --version
terraform --version
```

### Paso C: Configurar Credenciales de AWS
1. Ve a la consola de AWS, busca el servicio **IAM**.
2. Crea un usuario (ej. `devops-practice-user`) y otórgale políticas administrativas (puedes usar la política administrada `AdministratorAccess` para propósitos de aprendizaje, pero recuerda desactivarla o borrar las llaves después de tu estudio).
3. Ve a la pestaña **Security credentials** del usuario y genera una **Access Key** (tipo CLI).
4. Guarda el **Access Key ID** y el **Secret Access Key** en un lugar seguro. **¡Nunca los subas a GitHub!**
5. En tu terminal local de PowerShell, ejecuta:
   ```powershell
   aws configure
   ```
6. Ingresa los datos solicitados:
   *   `AWS Access Key ID [None]:` (Pega tu Access Key ID)
   *   `AWS Secret Access Key [None]:` (Pega tu Secret Access Key)
   *   `Default region name [None]:` `us-east-1` (o tu región preferida, ej. `us-east-2` o `us-west-2`)
   *   `Default output format [None]:` `json`

Puedes verificar que la conexión funciona ejecutando:
```powershell
aws sts get-caller-identity
```
Si te devuelve tu Account ID y el ARN del usuario, estás listo para desplegar infraestructura.

---

## 3. Ejercicio Práctico Comparativo

Para ver las diferencias en acción, crearemos exactamente la misma infraestructura básica con ambas herramientas:
1.  Una **VPC** (Virtual Private Cloud).
2.  Una **Subred Pública** dentro de la VPC.
3.  Un **Internet Gateway** conectado a la VPC.
4.  Una **Tabla de Ruteo** para enrutar el tráfico de la subred pública a Internet.
5.  Una instancia **EC2 (t2.micro)** dentro de esa subred.

---

### Flujo de Trabajo Práctico con Terraform
El código se encuentra en el directorio: [terraform_exercise](file:///C:/Users/TP/.gemini/antigravity/scratch/devops_job_application/terraform_exercise)

1.  Navega al directorio:
    ```powershell
    cd C:\Users\TP\.gemini\antigravity\scratch\devops_job_application\terraform_exercise
    ```
2.  Inicializa el directorio de trabajo (descarga el proveedor de AWS):
    ```powershell
    terraform init
    ```
3.  Revisa el plan de ejecución:
    ```powershell
    terraform plan
    ```
4.  Aplica los cambios para crear la infraestructura en tu cuenta real de AWS:
    ```powershell
    terraform apply -auto-approve
    ```
5.  **Para limpiar (¡Super importante para evitar costos!):**
    ```powershell
    terraform destroy -auto-approve
    ```

---

### Flujo de Trabajo Práctico con CloudFormation
El archivo de plantilla YAML se encuentra en: [cloudformation_exercise/vpc_ec2_template.yaml](file:///C:/Users/TP/.gemini/antigravity/scratch/devops_job_application/cloudformation_exercise/vpc_ec2_template.yaml)

1.  Navega al directorio:
    ```powershell
    cd C:\Users\TP\.gemini\antigravity\scratch\devops_job_application\cloudformation_exercise
    ```
2.  Valida que la plantilla no tenga errores de sintaxis:
    ```powershell
    aws cloudformation validate-template --template-body file://vpc_ec2_template.yaml
    ```
3.  Despliega la plantilla como un **Stack** llamado `mi-primer-stack-devops` pasándole un parámetro para el nombre de la llave de tu servidor EC2 (debes tener un Key Pair creado en tu consola de AWS en la región seleccionada, ej. `mi-key-pair`):
    ```powershell
    aws cloudformation create-stack --stack-name mi-primer-stack-devops --template-body file://vpc_ec2_template.yaml --parameters ParameterKey=KeyName,ParameterValue=mi-key-pair
    ```
4.  Monitorea el progreso del despliegue en la terminal:
    ```powershell
    aws cloudformation describe-stacks --stack-name mi-primer-stack-devops --query "Stacks[0].StackStatus"
    ```
    *(Esperar a que el estado sea `CREATE_COMPLETE`)*
5.  **Para limpiar (¡Super importante para evitar costos!):**
    ```powershell
    aws cloudformation delete-stack --stack-name mi-primer-stack-devops
    ```
    *(Esto eliminará automáticamente la VPC, la subred, el IGW y la instancia EC2 sin dejar residuos en tu cuenta).*
