# Base SearxNG image
FROM docker.io/searxng/searxng:latest

# --- Railway build args (optional) ---
ARG SEARXNG_BASE_URL
ARG SEARXNG_UWSGI_WORKERS
ARG SEARXNG_UWSGI_THREADS
ARG PORT

# --- Runtime env ---
ENV BASE_URL=${SEARXNG_BASE_URL}
ENV PORT=${PORT:-8080}
ENV UWSGI_WORKERS=${SEARXNG_UWSGI_WORKERS:-4}
ENV UWSGI_THREADS=${SEARXNG_UWSGI_THREADS:-4}
# Tell SearxNG where to read your settings
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml

# --- Copy your SearxNG config (settings.yml, limiter.toml, etc.) ---
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# --- Copy your custom engines into the app path SearxNG imports from ---
# (Matches your repo: searx/engines/webcrawlerapi*.py)
COPY ./searx/engines/webcrawlerapi*.py /usr/local/searxng/searx/engines/

# --- Entrypoint ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
