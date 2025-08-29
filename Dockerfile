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

# 1) Config (settings.yml, limiter.toml, etc)
COPY ./searxng /etc/searxng
COPY ./searxng /etc/searxng-backup

# 2) Copy whole repo to a temp dir; then place engines into SearxNG’s code path
COPY . /tmp/src

# Copy from whichever common source path exists. Fail loudly if nothing is found.
RUN set -eux; \
  dest="/usr/local/searxng/searx/engines"; \
  mkdir -p "$dest"; \
  copied="0"; \
  for p in \
    /tmp/src/searxng/searx/engines \
    /tmp/src/searx/engines \
    /tmp/src/searx/searx/engines \
  ; do \
    if [ -d "$p" ]; then \
      echo "Found engines at: $p"; \
      cp -v "$p"/webcrawlerapi.py "$dest"/ 2>/dev/null || true; \
      cp -v "$p"/webcrawlerapi_images.py "$dest"/ 2>/dev/null || true; \
    fi; \
  done; \
  echo "== Engines directory after copy =="; ls -la "$dest"; \
  # ensure at least the main engine is present
  test -f "$dest/webcrawlerapi.py" || (echo "ERROR: webcrawlerapi.py not found in repo" && exit 1)

# (Optional) 3) Import test at build time to catch syntax/import errors early
RUN python3 - <<'PY'
import importlib, sys
print("Importing custom engines…")
print(importlib.import_module("searx.engines.webcrawlerapi").__file__)
try:
    print(importlib.import_module("searx.engines.webcrawlerapi_images").__file__)
except Exception as e:
    print("Note: images engine import raised:", e, file=sys.stderr)
PY

# (Optional) list engines dir for build logs
RUN ls -la /usr/local/searxng/searx/engines | sed -n '1,200p'

# 4) Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
