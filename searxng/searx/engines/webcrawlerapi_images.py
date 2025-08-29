# searx/engines/webcrawlerapi_images.py

from json import loads
from urllib.parse import urlencode
from searx.engines import Engine
import logging

# SearxNG requires the 'name' variable to be defined at the top level.
# It must match the key in settings.yml.
name = "webcrawlerapi_images"

# This must be defined for the engine to be recognized by SearxNG
engine_type = "online"

class WebcrawlerApiImagesEngine(Engine):
    """
    SearxNG engine for WebCrawlerAPI images.
    """
    categories = ["images"]

    def request(self, query, params):
        # Access the API key from the self object, which gets it from settings.yml
        api_key = self.api_key

        if not api_key:
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
        
        params["url"] = f"https://api.webcrawlerapi.com/v1/images?{urlencode(payload)}"
        return params

    def response(self, resp):
        """
        Parses the JSON response from WebCrawlerAPI and returns a list of image results.
        """
        results = []
        try:
            data = loads(resp.text)
            for item in data.get("results", []):
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
            self.logger.error("WebcrawlerAPI Images parse error: %s", e)
        
        return results
