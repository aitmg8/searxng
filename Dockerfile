FROM docker.io/searxng:latest

ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# Config
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# ✅ Copy your custom engines into SearxNG’s code path
COPY ./searxng/searx/engines/webcrawlerapi.py /etc/searxng
COPY ./searxng/searx/engines/webcrawlerapi_images.py /etc/searxng

# (Optional: prove they’re there at build time)
RUN ls -la /usr/local/searxng/searx/engines | sed -n '1,200p'

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
