import feedparser
import time
import logging
import json
import flask

# Garmin devices have a poorly documented JSON response memory limit (around 8KB max),
# parse the feed, conver it to JSON and reduce the size as much as possible!

def format_date(date):
    return int(time.mktime(date))

def parse_feed(request):
    
    url = request.args.get('feedUrl')
    episodeId = request.args.get('episodeId')

    d = feedparser.parse(url)
    
    o = {}

    if episodeId:

        date = int(episodeId.split("_")[1])

        try:
            entry = list(filter(lambda entry : format_date(entry.published_parsed) == date, d.entries))[0]
            link = list(filter(lambda link : link['rel'] == 'enclosure', entry.links))[0]
            o['url'] = link.url
        except:
            pass

    else:

        o['title'] = d.channel.title
        o['author'] = d.channel.title
        o['image'] = d.channel.image.url

        o['feed'] = []

        for i, entry in enumerate(d.entries):

            max_items = request.args.get('max')

            if max_items and i >= int(max_items):
                break
                
            e = {}
            e['title'] = entry.title
            e['date'] = format_date(entry.published_parsed)

            duration = 0
            try:
                for digit in entry.itunes_duration.split(':'):
                    duration = duration*60 + int(digit)
            except:
                pass  
            e['length'] = duration

            o['feed'].append(e)

    r = flask.Response(
        response=json.dumps(o, separators=(',', ':')),
        status=200,
        mimetype="application/json")

    return r