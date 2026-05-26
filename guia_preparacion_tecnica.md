# Guía de Preparación Técnica: DevOps Mid-Junior

Felipe, basándome en la descripción de la vacante de **Ingeniero DevOps Mid Junior (FinTech)** y cruzándola con tu perfil (Full Stack Developer & DevOps Support con fuerte experiencia en Docker, Linux VPS y PostgreSQL), he estructurado esta guía. 

Tu perfil actual tiene bases muy sólidas en desarrollo y administración de servidores Linux tradicionales, lo cual es excelente. Tu mayor enfoque para esta prueba debe estar en cerrar la brecha hacia **Nube (AWS)**, **Infraestructura como Código (Terraform)**, **Orquestación (Kubernetes)** y **Monitoreo (Prometheus/Grafana)**.

---

## 1. AWS (Amazon Web Services)
En una FinTech, la alta disponibilidad, la resiliencia y la seguridad son fundamentales. AWS es el núcleo de su infraestructura.

### Conceptos Clave a Repasar:
*   **Networking (VPC - Virtual Private Cloud):**
    *   **Subredes Públicas vs. Privadas:** La base de datos (PostgreSQL) y las APIs internas deben ir en subredes privadas. Solo los Load Balancers o el NAT Gateway deben estar en subredes públicas.
    *   **Internet Gateway (IGW) y NAT Gateway:** IGW permite tráfico entrante/saliente de internet (subred pública). NAT Gateway permite que instancias en subredes privadas salgan a internet para actualizar paquetes o descargar dependencias, sin permitir conexiones entrantes directas.
    *   **Security Groups (SG) y Network ACLs (NACL):** SG actúa a nivel de instancia (con estado / stateful). NACL actúa a nivel de subred (sin estado / stateless).
*   **Cómputo:**
    *   **EC2 (Elastic Compute Cloud):** Conceptos de tipos de instancias, Key Pairs y User Data (scripts de inicialización).
    *   **ALB (Application Load Balancer):** Distribución de tráfico HTTP/HTTPS a nivel de capa 7 hacia grupos de destino (Target Groups).
    *   **ASG (Auto Scaling Group):** Escalado automático horizontal basado en métricas (CPU, memoria).
*   **Bases de Datos:**
    *   **RDS (Relational Database Service) para PostgreSQL:** Entender Multi-AZ (alta disponibilidad con replicación síncrona en otra zona de disponibilidad) y Read Replicas (escalabilidad de lectura asíncrona).
*   **Almacenamiento:**
    *   **S3 (Simple Storage Service):** Almacenamiento de objetos, control de versiones, políticas de bucket y encriptación.
*   **Seguridad:**
    *   **IAM (Identity and Access Management):** Roles, Políticas (JSON), Grupos e Usuarios. Regla del **menor privilegio** (least privilege). Nunca uses credenciales root; usa roles de IAM asignados a instancias de EC2 o pods.

---

## 2. Infraestructura como Código (IaC) - Terraform
Terraform te permite definir toda la infraestructura anterior en archivos de configuración declarativos (`.tf`).

### Conceptos Clave a Repasar:
*   **Ciclo de Vida:**
    *   `terraform init`: Descarga los proveedores (AWS, etc.) y configura el backend.
    *   `terraform plan`: Muestra los cambios que se realizarán sin aplicarlos (dry run). Es crucial revisar esto en producción.
    *   `terraform apply`: Ejecuta los cambios.
    *   `terraform destroy`: Elimina todos los recursos gestionados.
*   **Estado de Terraform (`terraform.tfstate`):**
    *   Mapea los recursos del mundo real con tu configuración de código.
    *   **Best Practice:** Nunca guardes el estado en Git. Usa un **Remote Backend** (como un bucket de S3 para guardar el archivo de estado y una tabla de DynamoDB para bloqueo de estado / state locking para evitar colisiones entre miembros del equipo).
*   **Componentes del Código:**
    *   `provider`: Define a dónde se conecta Terraform (ej. `provider "aws" { region = "us-east-1" }`).
    *   `resource`: Define qué recurso crear (ej. `resource "aws_instance" "web" { ... }`).
    *   `variable` y `output`: Para parametrizar el código y exportar valores útiles (ej. la IP pública generada).
    *   **Módulos:** Bloques lógicos reutilizables de código de Terraform.

---

## 3. Contenedores y Orquestación - Docker y Kubernetes

### Docker (Conceptos Avanzados):
*   **Multi-stage Builds:** Esencial para reducir el tamaño de las imágenes de producción y mejorar la seguridad (ej. compilar tu aplicación Node.js/Angular en una etapa y copiar solo los archivos compilados a una imagen final ligera como `alpine` o `distroless`).
*   **Seguridad de Imágenes:** No correr contenedores como `root` (usar la instrucción `USER node` o similar), y escanear imágenes en busca de vulnerabilidades (Trivy, Snyk).

### Kubernetes (K8s) (Conceptos Básicos-Medios):
*   **Arquitectura Básica:** Control Plane (API Server, etcd, Scheduler, Controller Manager) y Worker Nodes (Kubelet, Kube-proxy, Container Runtime).
*   **Objetos Fundamentales (Manifiestos YAML):**
    *   **Pod:** La unidad mínima de ejecución en K8s (uno o más contenedores).
    *   **Deployment:** Define el estado deseado de tus pods (réplicas, estrategia de despliegue como RollingUpdate).
    *   **Service:** Abstracción para exponer tus pods a la red.
        *   `ClusterIP`: Solo interno al cluster.
        *   `NodePort`: Expone el puerto del nodo.
        *   `LoadBalancer`: Crea un balanceador de carga en la nube (ej. AWS ELB).
    *   **ConfigMap y Secret:** Para inyectar configuraciones y credenciales como variables de entorno o volúmenes montados.
    *   **Ingress:** Reglas de enrutamiento HTTP/HTTPS externas administradas por un Ingress Controller (ej. Nginx Ingress Controller).

---

## 4. Gestión de Configuración - Ansible
Ansible se usa para configurar sistemas operativos y desplegar aplicaciones en servidores ya existentes.

### Conceptos Clave a Repasar:
*   **Diferencia clave con Terraform:** Terraform aprovisiona la infraestructura (crea la máquina virtual). Ansible configura la infraestructura (instala Nginx, crea usuarios, configura Docker en la máquina).
*   **Componentes:**
    *   **Inventory:** Archivo de texto que lista las direcciones IP de los servidores a gestionar.
    *   **Playbooks:** Archivos YAML que definen una lista de tareas (tasks) a ejecutar en orden.
    *   **Modules:** Herramientas listas para usar dentro de Ansible (ej. `apt`, `yum`, `service`, `copy`).
    *   **Roles:** Estructura organizada para reutilizar código de Ansible.
*   **Idempotencia:** Característica de Ansible que garantiza que si ejecutas el playbook varias veces, solo realizará cambios si el estado del servidor difiere del deseado.

---

## 5. Monitoreo y Observabilidad - Prometheus y Grafana
En el sector financiero, debes saber inmediatamente si una API cae o si la base de datos PostgreSQL está sobrecargada.

### Conceptos Clave a Repasar:
*   **Prometheus:**
    *   **Pull Architecture:** Prometheus "raspa" (scrapes) métricas de los endpoints de tus servicios en intervalos regulares (por defecto expuestos en `/metrics`).
    *   **Exporters:** Traductores de métricas para sistemas que no exponen Prometheus nativamente (ej. `Node Exporter` para métricas del sistema operativo, `Postgres Exporter` para PostgreSQL).
    *   **PromQL:** El lenguaje de consultas de Prometheus para buscar métricas y crear alertas.
*   **Grafana:**
    *   Plataforma de visualización. Se conecta a Prometheus como "Data Source".
    *   Diseño de paneles y tableros interactivos (métricas de CPU, memoria, throughput de red, errores 5xx HTTP).

---

## 6. PostgreSQL y Linux
*   **Linux:**
    *   Gestión de servicios con `systemd` (`systemctl status/start/stop/restart`).
    *   Revisión de logs usando `journalctl -u nginx -n 50 --no-pager`.
    *   Uso de comandos de diagnóstico de red y procesos: `top`/`htop`, `df -h` (disco), `free -m` (memoria), `netstat` / `ss -tulpn` (puertos abiertos).
*   **PostgreSQL:**
    *   Cómo hacer respaldos con `pg_dump` y restaurarlos con `pg_restore` o `psql`.
    *   Concepto de indexación (para optimizar consultas lentas) y configuración básica del archivo `postgresql.conf` (como `shared_buffers`, `work_mem`).
    *   Monitorear conexiones activas (`pg_stat_activity`).

---

## 7. CI/CD (Integración y Despliegue Continuos)
Dado que ya conoces **GitHub Actions**, estás en buen camino. Enfócate en:
*   **Estructura de un Pipeline Eficiente:**
    1.  **Build / Test / Lint:** Ejecutar pruebas unitarias y linters antes de compilar.
    2.  **Containerize:** Crear la imagen de Docker usando caché para que el build sea rápido.
    3.  **Security Scan:** Escaneo de seguridad del código y la imagen de Docker.
    4.  **Publish:** Subir la imagen a un registro de contenedores (Docker Hub, AWS ECR).
    5.  **Deploy:** Actualizar la infraestructura. Si es en K8s, actualizar la imagen en el manifiesto y aplicar (`kubectl apply` o via Helm/ArgoCD). Si es en una instancia tradicional, hacer un deploy controlado.
