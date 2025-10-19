# Multi-stage build for Kaitai Struct Web IDE

# Stage 1: Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files and build scripts needed for installation
COPY package.json package-lock.json ./
COPY vendor.yaml ./
COPY vendor_build.js ./
COPY vendor_license.js ./

# Copy lib directory (needed by vendor_license.js during npm install)
COPY lib/ ./lib/

# Create docs/wiki directory (needed by vendor_license.js to write 3rd-party-libraries.md)
RUN mkdir -p docs/wiki

# Install dependencies (this will also run vendor_build.js via postinstall)
RUN npm ci

# Copy source files
COPY tsconfig.json tsconfig.worker.json tsconfig.playground.json ./
COPY tslint.json ./
COPY src/ ./src/
COPY genKaitaiFsFiles.js ./

# Compile TypeScript
RUN npx tsc

# Copy additional TypeScript configs and compile worker/playground if needed
RUN npx tsc -p tsconfig.worker.json || true
RUN npx tsc -p tsconfig.playground.json || true

# Copy static assets and other necessary files
COPY css/ ./css/
COPY formats/ ./formats/
COPY samples/ ./samples/
COPY docs/ ./docs/
COPY index.html v2.html Playground.html github_oauth.html ./
COPY LICENSE LICENSE-3RD-PARTY.txt ./
COPY README.md ./

# Stage 2: Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files for reference
COPY package.json package-lock.json ./

# Copy node_modules from builder (includes all dependencies needed for serve.js)
COPY --from=builder /app/node_modules ./node_modules

# Copy built artifacts from builder stage
COPY --from=builder /app/js ./js
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/css ./css
COPY --from=builder /app/formats ./formats
COPY --from=builder /app/samples ./samples
COPY --from=builder /app/docs ./docs
COPY --from=builder /app/index.html /app/v2.html /app/Playground.html /app/github_oauth.html ./
COPY --from=builder /app/LICENSE /app/LICENSE-3RD-PARTY.txt /app/README.md ./

# Copy server files
COPY serve.js ./
COPY genKaitaiFsFiles.js ./

# Expose port 8000 (default port used by serve.js)
EXPOSE 8000

# Set environment variables
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8000/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "serve.js"]

