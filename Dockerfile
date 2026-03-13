# Stage 1: Build
FROM node:20-slim AS build

WORKDIR /app

# Install build dependencies for better-sqlite3 (native compilation)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy source and config
COPY src/ ./src/
COPY tsconfig.json ./

# Build TypeScript
RUN npm run build

# Stage 2: Runtime
FROM node:20-slim

WORKDIR /app

# Copy compiled dist and node_modules from build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json ./

# Create non-root user
RUN groupadd --system appgroup && useradd --system --ingroup appgroup appuser

# Switch to non-root user
USER appuser

# Entry point
CMD ["node", "dist/index.js"]
