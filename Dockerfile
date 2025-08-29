# ---- Base image ----
FROM docker.io/searxng/searxng:latest

# ---- Railway build-time args (optional) ----
ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

# ---- Runtime env ----
ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}

# Point SearxNG to your config (change if your path differs)
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# ---- Copy config ----
# Expecting repo layout:
# searxng/settings.yml
# searxng/ (any other config fragments you keep)
COPY ./searxng /etc/searxng
# Optional backup for volume scenarios
COPY ./searxng /etc/searxng-backup

# ---- Copy custom engine code into the app path SearxNG imports from ----
# Expecting repo layout:
# searxng/searx/engines/webcrawlerapi.py
# searxng/searx/engines/webcrawlerapi_images.py
COPY ./searxng/searx/engines/webcrawlerapi.py         /usr/local/searxng/searx/engines/
COPY ./searxng/searx/engines/webcrawlerapi_images.py  /usr/local/searxng/searx/engines/

# ---- Entrypoint (your script) ----
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# (Optional) Simple healthcheck for readiness
# HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD wget -qO- "http://127.0.0.1:${PORT:-8080}/" > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
