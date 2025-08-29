# /searx/engines/webcrawlerapi.py
from json import loads
from urllib.parse import urlencode
from searx.engines import Engine

# This must be defined for the engine to be recognized by SearxNG
engine_type = "online"

# The name of the engine, usually the same as the file name without .py
name = "webcrawlerapi"

class WebcrawlerApiEngine(Engine):
    """
    SearxNG engine for WebCrawlerAPI.
    """

    def request(self, query, params):
        # We can access engine-specific settings from the `self` object.
        # The API key is defined in settings.yml under `api_key`.
        api_key = self.api_key

        if not api_key:
            # Handle case where API key is missing
            self.logger.error("WebcrawlerAPI: API key not configured.")
            return

        payload = {
            "q": query,
            "api_key": api_key,
            "page": params["pageno"],
            "num": params["number_of_results"]
        }

        # SearxNG's Engine class has a built-in `request` method that takes a URL.
        # We just need to construct the URL and pass it.
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
