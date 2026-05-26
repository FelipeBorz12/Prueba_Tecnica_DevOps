# =========================================================================
# ETAPA 1: Construcción e Instalación de Dependencias
# =========================================================================
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copiar archivos de dependencias para aprovechar la caché de capas de Docker
COPY package*.json ./

# Instalar dependencias de producción de forma limpia
RUN npm install --omit=dev

# =========================================================================
# ETAPA 2: Imagen Final de Producción (Ligera y Segura)
# =========================================================================
FROM node:20-alpine

WORKDIR /usr/src/app

# Copiar dependencias y código fuente desde la etapa de construcción
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY package.json ./
COPY src/ ./src/

# Configurar variables de entorno por defecto
ENV PORT=3000
ENV NODE_ENV=production

# Usar el usuario de Node no-root por seguridad (ya está pre-creado en alpine)
USER node

# Exponer el puerto de la aplicación
EXPOSE 3000

# Comando para ejecutar la aplicación
CMD ["npm", "start"]
