# Base SearXNG image
FROM docker.io/searxng/searxng:latest

# --- Railway build args (non-sensitive, injected by Railway) ---
ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

# --- Runtime environment ---
ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# --- Copy configuration into container ---
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# --- Debug: print what files exist in context (very useful in Railway logs) ---
RUN echo "== Build context ==" && ls -la && \
    echo "== searxng dir ==" && ls -la searxng || true && \
    echo "== searxng/searx dir ==" && ls -la searxng/searx || true && \
    echo "== searxng/searx/engines dir ==" && ls -la searxng/searx/engines || true && \
    echo "== searx/searx/engines (alt path) ==" && ls -la searx/searx/engines || true

# --- Copy custom engines into app path ---
RUN set -eux; \
    dest="/usr/local/searxng/searx/engines"; \
    mkdir -p "$dest"; \
    if [ -d "searxng/searx/engines" ]; then \
        cp -v searxng/searx/engines/webcrawlerapi*.py "$dest"/ || true; \
    fi; \
    if [ -d "searx/searx/engines" ]; then \
        cp -v searx/searx/engines/webcrawlerapi*.py "$dest"/ || true; \
    fi; \
    # Fail clearly if nothing got copied
    ls -la "$dest" | grep -E 'webcrawlerapi.*\.py' >/dev/null || (echo "ERROR: webcrawlerapi*.py not found in build context" && exit 1)

# --- Entrypoint ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
