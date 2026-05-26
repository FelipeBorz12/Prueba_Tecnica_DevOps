# Guía DevOps: Ciclo de Vida y Entornos para Proyecto de Trading (Binance API)

Felipe, liderar la infraestructura de un proyecto de **trading con la API de Binance** es un reto sumamente crítico y emocionante. En FinTech y Trading, el foco principal de DevOps cambia de "escalabilidad masiva" a **Seguridad Extrema (claves API de Binance)**, **Baja Latencia (ejecución rápida de órdenes)** y **Confiabilidad Absoluta (evitar pérdidas financieras por caídas de software)**.

A continuación, se detalla qué espera el equipo de desarrollo de ti y cómo debes estructurar los entornos y la documentación.

---

## 🚀 FASE 1: Antes de que empiecen a programar (Preparación)

El objetivo de esta fase es pavimentar el camino para que los desarrolladores arranquen sin fricciones, de forma segura y con un entorno estandarizado.

### 1. Entorno de Desarrollo Local (Lo que entregas al Dev)
Los desarrolladores necesitan escribir código en sus máquinas locales de manera idéntica a producción.
*   **Dockerizar la aplicación:** Crea el `Dockerfile` base y un `docker-compose.yml` local.
*   **Simulación de Binance (Binance Testnet):** Los devs no pueden probar bots de trading con dinero real. Binance ofrece una red de pruebas (Testnet). Debes proveer variables de entorno en el compose local que apunten a los endpoints de la Testnet de Binance.
*   **Base de datos local:** Incluir en el compose la base de datos (Postgres/Redis) ya configurada para que ellos solo tengan que hacer `docker compose up` y empezar a codificar.

### 2. Gestión de Credenciales y Secretos (Seguridad)
*   **Binance API Keys:** Necesitas definir cómo se guardarán y accederán las claves de API.
    *   **En Dev/Staging:** Usar llaves de la Testnet de Binance (sin fondos reales).
    *   **En Producción:** **NUNCA** guardarlas en archivos `.env` en el servidor ni mucho menos en Git. Debes configurar un gestor de secretos (como **AWS Secrets Manager** o **HashiCorp Vault**) para inyectarlas directamente en memoria al contenedor al arrancar.
*   **Permisos de las llaves:** Las llaves de producción solo deben tener permisos de *Trading*. El permiso de *Retiro (Withdrawals)* debe estar desactivado por seguridad.

### 3. Estrategia de Ramas y Repositorios
*   Definir el flujo de Git (ej: **Trunk-based development** para startups o **GitFlow**).
*   Configurar el repositorio con reglas de protección para la rama `main` (requerir Pull Requests aprobados, pruebas de CI exitosas antes de mezclar).

---

## 🔄 FASE 2: Durante el Desarrollo (Integración Continua)

Mientras el equipo programa, tú automatizas la validación y el despliegue de sus cambios en entornos de prueba.

### 1. Pipeline de CI (Integración Continua)
Cada vez que un desarrollador sube código a una rama o hace un PR:
*   **Linter y Tests:** Ejecutar pruebas unitarias de forma automática.
*   **Security Scanning (SAST):** Escanear el código en busca de secretos hardcodeados (con herramientas como `GitGuardian` o `Trivy`) y vulnerabilidades en dependencias.
*   **Build de Imagen:** Compilar la imagen de Docker y subirla a un registro privado (ej: AWS ECR).

### 2. Entorno de Staging (Pruebas / CD)
*   Configura un despliegue continuo (CD) automatizado para que cuando un PR se fusione a la rama `develop`, se despliegue automáticamente en un entorno de pruebas (Staging).
*   Este entorno debe usar variables que apunten a la API de pruebas de Binance para hacer simulaciones completas de trading (Paper Trading).

---

## 🚀 FASE 3: Después / Lanzamiento y Mantenimiento (Producción)

Cuando el código está listo para salir a producción con dinero real, tu enfoque es la estabilidad y la observabilidad.

### 1. Arquitectura de Baja Latencia en AWS (Terraform)
*   **Cointegración geográfica:** Binance aloja sus servidores principalmente en **AWS en la región de Tokio (ap-northeast-1)** o **Londres (eu-west-2)**. Para reducir la latencia de red al enviar órdenes de trading (donde los milisegundos importan), debes desplegar tus servidores EC2/ECS en la misma región física de AWS donde Binance tiene sus endpoints.
*   **Alta Disponibilidad:** Aunque el bot corra en un servidor, debes prever qué pasa si ese servidor se cae. Configurar reinicios automáticos rápidos.

### 2. Monitoreo Activo (Prometheus + Grafana + Alertmanager)
En trading, si el bot se detiene o pierde la conexión a internet, la empresa puede perder miles de dólares por no cerrar una posición. Debes monitorear:
*   **Límites de Tarifa (Rate Limits) de Binance:** Binance banea IPs que superen un número de peticiones por minuto. Debes monitorear las cabeceras HTTP de respuesta de Binance y alertar si se está cerca del límite (código HTTP 429).
*   **Latencia de la API:** Tiempo de respuesta de las órdenes.
*   **Salud del Proceso:** Alertas inmediatas al canal de Telegram/Slack del equipo de ingeniería si el bot de trading se detiene (código de salida diferente de cero).
*   **Balance del API:** Monitorear el balance de la cuenta para alertar si se está quedando sin fondos para operar o pagar comisiones.

### 3. Centralización de Logs (Observabilidad)
*   Los desarrolladores **no deben tener acceso por SSH a producción** para ver por qué falló una operación. Debes centralizar los logs (con herramientas como AWS CloudWatch, Grafana Loki o Elasticsearch) para que ellos los consulten de forma segura desde un panel web.

---

## 📄 Resumen de Documentación Necesaria (Tu Entregable)

Como DevOps, debes redactar e incluir en el repositorio los siguientes archivos Markdown:

1.  **`README.md` de Desarrollo Local:**
    *   Requisitos para correr el proyecto (Docker, Docker Compose).
    *   Comandos rápidos (`docker compose up --build`, cómo correr tests locales).
    *   Variables de entorno necesarias (archivo `.env.example`).
2.  **Documento de Arquitectura de Entornos:**
    *   Diagrama de red (VPC, subredes, balanceadores, bases de datos).
    *   Ubicación geográfica de los servidores y justificación de latencia.
3.  **Guía de Despliegue (Runbook):**
    *   Cómo se realiza un despliegue manual en caso de emergencia.
    *   Cómo hacer un rollback (regresar a una versión anterior del bot de inmediato si falla en producción).
4.  **Matriz de Secretos:**
    *   Listado de qué variables son secretas, quién tiene acceso a ellas y en qué bóveda (Vault/Secrets Manager) están guardadas.
