# ---- Base image ----
FROM node:20-alpine

# ---- Set working directory ----
WORKDIR /usr/src/app

# ---- Install dependencies first (better layer caching) ----
COPY package*.json ./
RUN npm install --production

# ---- Copy app source ----
COPY . .

# ---- Expose port ----
EXPOSE 3000

# ---- Healthcheck ----
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD wget -qO- http://localhost:3000/health || exit 1

# ---- Start app ----
CMD ["node", "server.js"]
