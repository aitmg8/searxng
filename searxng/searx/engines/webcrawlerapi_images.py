# /searx/engines/webcrawlerapi_images.py
from json import loads
from urllib.parse import urlencode
from searx.engines import Engine
import logging

# Set up a logger for this module
logger = logging.getLogger(__name__)

# This must be defined for the engine to be recognized by SearxNG
engine_type = "online"

# The name of the engine, usually the same as the file name without .py
name = "webcrawlerapi_images"

class WebcrawlerApiImagesEngine(Engine):
    """
    SearxNG engine for WebCrawlerAPI images.
    """
    # The categories are now defined within the class or in settings.yml
    # Setting them here is the default, but settings.yml will override it.
    categories = ["images"]

    def request(self, query, params):
        # We can access engine-specific settings from the `self` object.
        api_key = self.api_key
        
        if not api_key:
            # Handle case where API key is missing
            self.logger.error("WebcrawlerAPI Images: API key not configured.")
            return

        page = max(1, int(params.get("pageno", 1)))
        num = max(1, int(params.get("number_of_results", 10)))

        payload = {
            "q": query,
            "api_key": api_key,
            "page": page,
            "num": num,
        }
        
        # Construct the URL for the request
        params["url"] = f"https://api.webcrawlerapi.com/v1/images?{urlencode(payload)}"
        
        # The timeout is now part of the `settings.yml` and is handled by the framework
        # You don't need to manually set it in the params dictionary
        
        return params

    def response(self, resp):
        """
        Parses the JSON response from WebCrawlerAPI and returns a list of image results.
        """
        results = []
        try:
            data = loads(resp.text)
            for item in data.get("results", []):
                # We need to provide a complete set of image-related fields
                thumb = item.get("thumbnail") or item.get("thumbnail_url") or ""
                src = item.get("image") or item.get("url") or ""
                page_url = item.get("source") or item.get("page_url") or item.get("url") or ""
                
                results.append({
                    "template": "images.html",
                    "title": item.get("title", "") or item.get("alt", "") or "",
                    "img_src": src,
                    "thumbnail": thumb or src,
                    "url": page_url or src,
                })
        except Exception as e:
            # Use the logger for better error handling in SearxNG
            self.logger.error("WebcrawlerAPI Images parse error: %s", e)
        
        return results
