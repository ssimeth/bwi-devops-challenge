# ===========================================
# BUILD STAGE
# ===========================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with error checking
RUN npm ci && npm list --depth=0

# Copy source code
COPY . .

# Verify package.json and build
RUN test -f package.json && npm run --silent || (echo "Available scripts:" && npm run)
ENV NODE_ENV=production
RUN npm run build

# ===========================================
# PRODUCTION STAGE
# ===========================================
FROM nginx:1.25-alpine AS production

# Security: Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001 -G nginx

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy built React app from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create nginx directories with proper permissions
RUN mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html

# Labels for metadata
LABEL org.opencontainers.image.title="KVInfoSys Frontend" \
      org.opencontainers.image.description="Simple Frontend for BWI DevOps Demo" \
      org.opencontainers.image.vendor="BWI GmbH"

# Switch to non-root user
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/nginx-health || exit 1

# Expose port
EXPOSE 8080

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
