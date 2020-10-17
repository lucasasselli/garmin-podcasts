# Garmin IQ Podcasts

<img src="graphics/icon.png" align="left" width="200" hspace="10" vspace="10">
   
Podcast is a Garmin Connect IQ podcast app powered by [Podcast Index](https://podcastindex.org). 

It requires no external service or subscription. The app manages a library of subscribed podcasts and automatically synchronizes the lastest episodes for each.

If you like this app and you want to show your support you can [pay me a beer](https://paypal.me/lucasasselli)! :beer:

[<img src="https://developer.garmin.com/static/available-badge-9e49ebfb7336ce47f8df66dfe45d28ae.svg" width="200">](https://apps.garmin.com/en-US/apps/b5b85600-0625-43b6-89e9-1245bd44532c)

## Features
- Free
- No external service or subscription required
- Playback queue
- Support for episode artwork and metadata

## TODO
Most of the limitations of the app are directly related to the Garmin SDK or Podcast index API. Garmin devices are able to parse JSON responses of around 16k, and currently Podcast Index API gives pretty fat responses, so navigating individual podcasts episodes is currently impossible without saturating the memory.

- Allow the user to download individual episodes
- Add localisation
- Support more Garmin devices

## How to build

1. Download the latest version of [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/);
2. Get a [Podcast Index API token](https://api.podcastindex.org/);
3. Set the API token and secret in `app/source/Secrets.mc.example` and save it as `app/source/Secrets.mc`.
