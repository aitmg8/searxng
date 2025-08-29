FROM docker.io/searxng/searxng:latest

ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# Config (your settings.yml lives under ./searxng)
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# ✅ Correct source paths for engines (pick one of the options)
# Option A: copy the entire engines dir
COPY ./searxng/searx/engines/ /usr/local/searxng/searx/engines/
# Option B: copy individually (comment A if you use B)
# COPY ./searxng/searx/engines/webcrawlerapi.py        /usr/local/searxng/searx/engines/
# COPY ./searxng/searx/engines/webcrawlerapi_images.py /usr/local/searxng/searx/engines/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
