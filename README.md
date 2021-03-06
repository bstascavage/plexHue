plexHue
=======

Program to integrate Plex with the Philips Hue.

## Introduction
This program is meant to sync your Philip Hue lightbulbs with your Plex playback.  It does the following:

1.  Slowly dims your lights until they are off whenever a movie starts.
2.  Brings your lights to half-brightness when a movie is paused.
3.  Slowly brightens your lights when a movie is stopped until it is at full brightness.

Video: https://www.youtube.com/watch?v=W3FJ6tHxiDg  

## Prerequisites
1.  Ruby installed (at least version 1.9.3) and ruby-dev.
2.  Your Philip Hue Hub up and configured.
3.  A PlexPass membership (Sorry about this, but the API to see when something is played is a PlexPass feature :( )

## Installation (Debian/Ubuntu)
1.  Change to the `/opt` directory.
2.  Clone this repo on your server:

    `git clone https://github.com/bstascavage/plexHue.git`
3.  Change to the plexHue directory
4.  Install the blunder gem (http://bundler.io/)

    `gem install bundler`
5.  Install the gem dependecies:

    `bundle install`
6.  Copy the init script to your init.d directory:

    `cp debian/init/plexHue /etc/init.d/plexHue`
7.  Setup your config file (see below for details on parameters)
8.  Press the HOME button on your Philips Hue Hub
9.  Start the plexHue service

    `service plexHue start`
10.  Check the plexHue log to ensure that the program paired with your hub:

    `tail -f plexHue.log`
    
## Config file

##### plex
`server` - IP address of your Plex server.  Defaults to `localhost`.  Optional.

`machineIdentifier` - Unique identifier of your Plex client.  You can find this by starting up a video on your device and then running `bin/getMachineID.rb` and finding your device in the output.  Required.

`api_key` - Your Plex API key.  This can be found by searching for your device here (it is the 'token' field): https://plex.tv/devices.xml.  Required.

##### hue
`hub_ip` - IP addres of your Philips Hue Hub.  You can get this by visiting http://www.meethue.com/api/nupnp while on the same network as your hub.  Required.

`starttransitiontime` - How long it takes to dim the lights when starting a video, in multiples of 100ms.  Defaults to 3 seconds.  Optional.

`pausedtransitiontime` - How long it takes to brighten the lights when pausing a video, in multiples of 100ms.  Defaults to 3 seconds.  Optional.

`stoptransitiontime` - How long it takes to brighten the lights when stopping a video, in multiples of 100ms.  Defaults to 3 seconds.  Optional.

`lights` - Array of names of the lights you want to use, in the format: ["light1", "light2", "light3"].  Required.


## Notes
1.  This software is still in alpha.  There are plenty of features and options that I plan on implementing, plus more streamlined support for different OSes.  Bug fixes take priority over features.  If you have any issues, or anything you'd like added, please open a Github issue.
2.  This program is developed with the Hue Lux bulbs, though regular Hue bulbs should work just fine.  Because of that, there is no support for color at the moment.  This might change down the road, but not anytime soon.
