FROM docker.io/searxng/searxng:latest

# ---- Railway build args (optional) ----
ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

# ---- Runtime env ----
ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# ---- Debug: show what the build context actually contains ----
RUN echo "== Build context root ==" && ls -la || true

# ---- Copy config (two patterns supported) ----
# If you have a config directory at repo ./searxng (preferred):
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup
# If ./searxng doesn't exist, fall back to a single settings file at ./searx/settings.yml
# (this RUN block copies it if present and searxng/ wasn't copied)
RUN set -eux; \
    if [ ! -f /etc/searxng/settings.yml ] && [ -f "searx/settings.yml" ]; then \
        mkdir -p /etc/searxng; \
        cp -v searx/settings.yml /etc/searxng/settings.yml; \
    fi; \
    echo "== /etc/searxng listing =="; ls -la /etc/searxng || true

# ---- Copy custom engines into the app path ----
# We try three common repo layouts and copy any webcrawlerapi*.py we find.
RUN set -eux; \
    dest="/usr/local/searxng/searx/engines"; \
    mkdir -p "$dest"; \
    copied="0"; \
    if [ -d "searxng/searx/engines" ]; then \
        echo "Copying from searxng/searx/engines"; \
        cp -v searxng/searx/engines/webcrawlerapi*.py "$dest"/ 2>/dev/null || true; \
    fi; \
    if [ -d "searx/engines" ]; then \
        echo "Copying from searx/engines"; \
        cp -v searx/engines/webcrawlerapi*.py "$dest"/ 2>/dev/null || true; \
    fi; \
    if [ -d "searx/searx/engines" ]; then \
        echo "Copying from searx/searx/engines"; \
        cp -v searx/searx/engines/webcrawlerapi*.py "$dest"/ 2>/dev/null || true; \
    fi; \
    ls -la "$dest" | grep -E 'webcrawlerapi.*\.py' && copied="1" || true; \
    if [ "$copied" = "0" ]; then \
        echo "ERROR: webcrawlerapi*.py not found in build context. Expected in one of:"; \
        echo "  - searxng/searx/engines/"; \
        echo "  - searx/engines/"; \
        echo "  - searx/searx/engines/"; \
        exit 1; \
    fi

# ---- Entrypoint ----
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
