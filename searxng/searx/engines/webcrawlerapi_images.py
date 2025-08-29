# searx/engines/webcrawlerapi_images.py
from json import loads
from urllib.parse import urlencode
from typing import Dict, Any, List

engine_type = "online"
categories = ["images"]
paging = True

api_key = None
base_url = "https://api.webcrawlerapi.com/v1/images"
timeout = 5.0

def request(query: str, params: Dict[str, Any]) -> Dict[str, Any]:
    if not api_key:
        return params
    page = max(1, int(params.get("pageno", 1)))
    num = max(1, int(params.get("number_of_results", 10)))

    payload = {
        "q": query,
        "api_key": api_key,
        "page": page,
        "num": num,
    }
    params["url"] = f"{base_url}?{urlencode(payload)}"
    params["timeout"] = timeout
    return params


def response(resp) -> List[Dict[str, Any]]:
    results: List[Dict[str, Any]] = []
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
        print("webcrawlerapi_images parse error:", e)
    return results
