import feedparser
import time
import logging
import json

def parse_feed(request):
    d = feedparser.parse(request.args.get('url'))

    o = { 'feed': []}

    o['title'] = d.channel.title
    o['author'] = d.channel.title
    o['image'] = d.channel.image.url

    for i, entry in enumerate(d.entries):

        max_items = request.args.get('max')

        if max_items and i >= int(max_items):
            break

        e = {}

        e['title'] = entry.title
        e['datePublished'] = time.mktime(entry.published_parsed)

        links = list(filter(lambda link : link['rel'] == 'enclosure', entry.links))

        e['enclosureUrl'] = links[0].url
        e['duration'] = links[0].length
        o['feed'].append(e)

    return json.dumps(o)