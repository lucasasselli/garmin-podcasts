import feedparser
import time
import logging
import json
import flask

# Garmin devices have a poorly documented JSON response memory limit (around 8KB max),
# parse the feed and reduce the size as much as possible!

def format_date(date):
    return int(time.mktime(date))

def parse_feed(request):

    url = request.args.get('feedUrl')
    episodeId = request.args.get('episodeId')
    logging.info("Received feed request for " + url)

    d = feedparser.parse(url)
    if d.bozo:
        logging.error("Feed error: " + str(d.bozo_exception))
        return flask.Response(
            status=500,
            mimetype="application/json")

    o = {}

    if episodeId:
        # Requested single episode
        date = int(episodeId.split("_")[1])

        try:
            entry = list(filter(lambda entry : format_date(entry.published_parsed) == date, d.entries))[0]
            link = list(filter(lambda link : link['rel'] == 'enclosure', entry.links))[0]
        except:
            logging.error("Unable to find episode")
            return flask.Response(
                status=500,
                mimetype="application/json")

        o['title'] = entry.title
        o['url'] = link.url

        duration = 0
        try:
            for digit in entry.itunes_duration.split(':'):
                duration = duration*60 + int(digit)
        except:
            pass
        o['duration'] = duration

    else:
        # Requested entire feed
        o['title'] = d.channel.title
        o['image'] = d.channel.image.url

        o['feed'] = []
        for i, entry in enumerate(d.entries):

            max_items = request.args.get('max')

            if max_items and i >= int(max_items):
                break

            # Build an array for each episode to save memory!
            e = []
            e.append(entry.title[:100]) # Trim title aggressively!
            e.append(format_date(entry.published_parsed))

            o['feed'].append(e)

    return flask.Response(
        response=json.dumps(o, separators=(',', ':')),
        status=200,
        mimetype="application/json")