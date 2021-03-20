# Garmin IQ Podcasts

<img src="graphics/icon.png" align="left" width="200" hspace="10" vspace="10">
   
*Podcast* is a Garmin Connect IQ podcast app powered by [Podcast Index](https://podcastindex.org).  No external service or subscription required: all you need is you watch! 

Download your favorite episodes or keep your up-to-date with the most recent ones, organize your queue and resume listening from where you left.

If you like this app and you want to show your support you can [pay me a beer](https://paypal.me/lucasasselli)! :beer:

[<img src="https://developer.garmin.com/static/available-badge-9e49ebfb7336ce47f8df66dfe45d28ae.svg" width="200">](https://apps.garmin.com/en-US/apps/b5b85600-0625-43b6-89e9-1245bd44532c)

## Features
- Free and Open Source
- No external service or subscription required, just your watch!
- Download individual episodes or the most recent ones
- Configurable playback queue
- Episode progress tracking, resume from where you left
- gpodder.net support

## TODO
 - Support other podcast subscription services
 - Add other languages

## How to build
1. Download the latest version of [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/);
2. Get a [Podcast Index API token](https://api.podcastindex.org/);
3. Set the API token and secret in `app/source/Secrets.mc.example` and save it as `app/source/Secrets.mc`.
