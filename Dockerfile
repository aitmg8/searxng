# ✅ Updated to copy the new hyphenated file name.

FROM docker.io/searxng/searxng:latest

# Copy your custom configuration and engines
COPY ./searxng /etc/searxng
# Change the COPY command to use a hyphen
COPY ./searxng/searx/engines/webcrawlerapi.py /usr/local/searxng/searx/engines/
COPY ./searxng/searx/engines/webcrawlerapi-images.py /usr/local/searxng/searx/engines/

# Fix ownership of the copied files
RUN chown -R searxng:searxng /etc/searxng
RUN chown searxng:searxng /usr/local/searxng/searx/engines/webcrawlerapi.py || true
RUN chown searxng:searxng /usr/local/searxng/searx/engines/webcrawlerapi-images.py || true

# Run the entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
