# /searx/engines/webcrawlerapi.py

from json import loads
from urllib.parse import urlencode
import requests

# Engine metadata
engine_type = "online"
categories = ["general"]
paging = True

base_url = "https://api.webcrawlerapi.com/v1/search"

# This will be read from settings.yml
api_key = None

def request(query, params):
    global api_key
    if not api_key:
        return params

    payload = {
        "q": query,
        "api_key": api_key,
        "page": params["pageno"],
        "num": params["number_of_results"]
    }

    params["url"] = f"{base_url}?{urlencode(payload)}"
    return params

def response(resp):
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
        print("WebCrawlerAPI parse error:", e)

    return results
