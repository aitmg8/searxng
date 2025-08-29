FROM docker.io/searxng/searxng:latest

ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}
# Make sure SearxNG reads our config
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# --- Copy config (your repo's searxng/) ---
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# --- Copy custom engines (your repo has them under searx/engines/) ---
COPY ./searx/engines/webcrawlerapi*.py /usr/local/searxng/searx/engines/

# --- Prove files exist & are importable at build time ---
RUN set -eux; \
    echo "== Listing /usr/local/searxng/searx/engines =="; \
    ls -la /usr/local/searxng/searx/engines | sed -n '1,200p'; \
    python3 - <<'PY'
import importlib, pkgutil
print("== Import test: searx.engines.webcrawlerapi ==")
m = importlib.import_module("searx.engines.webcrawlerapi")
print("Loaded:", m.__file__)
try:
    m_images = importlib.import_module("searx.engines.webcrawlerapi_images")
    print("Loaded images:", m_images.__file__)
except Exception as e:
    print("Images engine import not required, but note:", e)
PY

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
