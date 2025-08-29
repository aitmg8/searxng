FROM docker.io/searxng/searxng:latest

# Use the environment variables that Railway injects at build time (non-sensitive ones)
ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

# Set Railway-specific environment variables
ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}

# Copy custom configuration to both locations (for volume mount scenarios)
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]