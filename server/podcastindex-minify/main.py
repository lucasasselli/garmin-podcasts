import requests
import logging
import json

KEYS_TO_KEEP = ["items", "id", "datePublished", "title", "duration", "feeds", "feed", "title", "author", "url", "image"]

def remove_from_json(d, keep):
    if isinstance(d, dict):
        for key in list(d.keys()):
            if key not in keep:
                del d[key]
            else:
                remove_from_json(d[key], keep)
    elif isinstance(d, list):
        for i in d:
            remove_from_json(i, keep)


def podcast_index_minify(request):

    headers = {
        "X-Auth-Date" : request.headers.get("X-Auth-Date"),
        "X-Auth-Key" : request.headers.get("X-Auth-Key"),
        "Authorization" : request.headers.get("Authorization")
    }

    query = request.script_root + request.full_path
    r = requests.get('https://api.podcastindex.org/' + query, headers=headers)

    j = json.loads(r.text)

    remove_from_json(j, KEYS_TO_KEEP)

    return json.dumps(j)