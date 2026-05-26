# Simulación de Prueba Técnica: DevOps Take-Home Challenge (FinTech)

Felipe, este es un diseño de prueba técnica realista para un nivel **DevOps Mid-Junior** en el sector financiero. En este reto simularás la implementación del entorno de producción para una API crítica de transacciones.

---

## 📋 Contexto del Reto
La startup FinTech "PayFast" tiene una API interna para registrar y verificar transacciones financieras en tiempo real. Esta API fue desarrollada en Node.js y se conecta a una base de datos PostgreSQL. Tu misión como Ingeniero DevOps es empaquetar la aplicación, automatizar el despliegue de la infraestructura en AWS usando Terraform, configurar el servidor con Ansible, configurar un pipeline de CI/CD con GitHub Actions, y monitorear la salud del sistema con Prometheus y Grafana.

---

## 🛠️ Requisitos Técnicos de la Entrega

### Tarea 1: Dockerización y Orquestación Local
1.  **Dockerfile:** Escribe un `Dockerfile` optimizado y seguro para la aplicación Node.js. Debe:
    *   Utilizar **Multi-stage builds** para mantener la imagen final ligera.
    *   No ejecutar el contenedor como usuario `root`.
2.  **Docker Compose:** Crea un archivo `docker-compose.yml` para desarrollo local que levante:
    *   El contenedor de la API (Node.js).
    *   Un contenedor de PostgreSQL con persistencia de datos (Volúmenes) y variables de entorno seguras.
    *   Una red interna para que se comuniquen.

### Tarea 2: Infraestructura como Código (Terraform)
Crea una configuración de Terraform para aprovisionar los recursos mínimos necesarios en AWS:
1.  **VPC y Redes:** Una VPC con una subred pública (para el servidor de aplicaciones) y una subred privada (donde idealmente iría RDS PostgreSQL).
2.  **Seguridad:** Security Groups que permitan:
    *   Acceso HTTP (puerto 80) e HTTPS (puerto 443) desde internet.
    *   Acceso SSH (puerto 22) restringido (por ejemplo, a tu IP pública).
    *   Acceso a la base de datos PostgreSQL (puerto 5432) solo desde la subred de la aplicación.
3.  **Cómputo:** Una instancia EC2 (`t3.micro` o `t2.micro`) con Linux (Ubuntu 22.04 LTS).

### Tarea 3: Configuración con Ansible
Escribe un playbook de Ansible (`playbook.yml`) para configurar el servidor EC2 creado:
1.  Actualizar los paquetes del sistema operativo.
2.  Instalar Docker y Docker Compose en la instancia.
3.  Asegurar que el servicio de Docker esté activo y configurado para iniciar en el arranque.
4.  Crear los directorios necesarios para desplegar la aplicación en el servidor.

### Tarea 4: Pipeline de CI/CD (GitHub Actions)
Crea un flujo de trabajo (`.github/workflows/deploy.yml`) que se ejecute al hacer push a la rama `main`:
1.  **Linter & Tests:** Ejecutar un paso simulado de linter y pruebas unitarias.
2.  **Build & Push:** Compilar la imagen de Docker de la API y subirla a un registro (puedes simularlo usando Docker Hub o AWS ECR con variables de secreto).
3.  **Deploy (Simulado u Opcional):** Un paso que se conecte vía SSH al servidor EC2 usando llaves SSH privadas almacenadas en los secretos de GitHub y ejecute el comando `docker compose pull && docker compose up -d` para actualizar la aplicación sin downtime prolongado.

### Tarea 5: Monitoreo y Observabilidad
Configura el monitoreo de la infraestructura y de la API localmente o en el servidor:
1.  Añadir un servicio de **Prometheus** al archivo `docker-compose.yml` para recopilar métricas.
2.  Añadir **Grafana** conectado a Prometheus como origen de datos.
3.  Configurar un exportador de métricas del sistema operativo (**Node Exporter**) para que Prometheus pueda raspar métricas de CPU y memoria del servidor.

---

## 📂 Estructura de Directorios Sugerida
Para resolver este reto, organiza tu repositorio de la siguiente manera:

```text
devops-challenge/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── app/
│   ├── src/
│   │   └── index.js       # Código fuente simulado de la API
│   ├── package.json
│   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   └── playbook.yml
├── monitoring/
│   ├── prometheus.yml
│   └── docker-compose.monitoring.yml
└── docker-compose.yml
```

---

## 💡 ¿Cómo empezar a resolverlo?
No tienes que hacerlo todo desde cero de inmediato. Si te parece bien, podemos ir resolviendo este reto paso a paso en tu directorio de trabajo. 

Podemos empezar por:
1.  **Crear el código de la API simulada y su Dockerfile.**
2.  **Configurar el docker-compose.yml local.**
3.  **Escribir los scripts de Terraform.**

Dime si estás listo y por cuál sección te gustaría empezar a codificar.
