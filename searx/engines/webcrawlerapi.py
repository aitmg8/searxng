from json import loads
from urllib.parse import urlencode
from typing import Dict, Any, List

engine_type = "online"
categories = ["general"]
paging = True
time_range_support = False

# read from settings.yml via !env
api_key = None
base_url = "https://api.webcrawlerapi.com/v1/search"
timeout = 5.0

def request(query: str, params: Dict[str, Any]) -> Dict[str, Any]:
    if not api_key:
        return params
    page = max(1, int(params.get("pageno", 1)))
    num = max(1, int(params.get("number_of_results", 10)))
    qs = urlencode({"q": query, "api_key": api_key, "page": page, "num": num})
    params["url"] = f"{base_url}?{qs}"
    params["timeout"] = timeout
    return params

def response(resp) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    data = loads(resp.text)
    for item in data.get("results", []):
        out.append({
            "title": item.get("title", "") or item.get("name", ""),
            "url": item.get("url", ""),
            "content": item.get("snippet", "") or item.get("description", ""),
        })
    return out
