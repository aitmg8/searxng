# /searx/engines/webcrawlerapi.py

from json import loads
from urllib.parse import urlencode
from searx.engines import Engine
import logging

# SearxNG requires the 'name' variable to be defined at the top level.
# It must match the key in settings.yml.
name = "webcrawlerapi"

# This must be defined for the engine to be recognized by SearxNG
engine_type = "online"

class WebcrawlerApiEngine(Engine):
    """
    SearxNG engine for WebCrawlerAPI.
    """
    # The categories are now defined within the class or in settings.yml
    # Setting them here is the default, but settings.yml will override it.
    categories = ["general"]

    def request(self, query, params):
        # Access the API key from the self object, which gets it from settings.yml
        api_key = self.api_key

        if not api_key:
            self.logger.error("WebcrawlerAPI: API key not configured.")
            return

        payload = {
            "q": query,
            "api_key": api_key,
            "page": params["pageno"],
            "num": params["number_of_results"]
        }

        # SearxNG's Engine class has a built-in `request` method that takes a URL.
        params["url"] = f"https://api.webcrawlerapi.com/v1/search?{urlencode(payload)}"
        return params

    def response(self, resp):
        """
        Parses the JSON response from WebCrawlerAPI and returns a list of results.
        """
        results = []
        try:
            data = loads(resp.text)
            for item in data.get("results", []):
                results.append({
                    "title": item.get("title", ""),
                    "url": item.get("url", ""),
                    "content": item.get("snippet", ""),
                })
        except Exception as e:
            # Use the logger for better error handling in SearxNG
            self.logger.error("WebCrawlerAPI parse error: %s", e)

        return results
