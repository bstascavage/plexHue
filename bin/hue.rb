#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'
require 'pp'

class Hue
    include HTTParty

    def initialize(config)
        $config = config
        self.class.base_uri "http://#{$config['hue']['hub_ip']}/api/newdeveloper//"
    end

    format :json

    def createGroup
        lights = self.class.get("lights")
        lightsPlex = []

        lights.each do | light |
            if $config['hue']['lights'].include? light[1]['name']
                lightsPlex.push(light[0])
            end
        end
        self.class.post("groups", :body => "{\"lights\": #{lightsPlex}, \"name\": \"plex\"}")
    end

    def deleteGroup
        groups = self.class.get("groups")

        groups.each do | group |
            if group[1]['name'] == 'plex'
                self.class.delete("groups/#{group[0]}")
            end
        end
    end

    def getPlexGroup
        groups = self.class.get("groups")

        groups.each do | group |
            if group[1]['name'] == 'plex'
                return group[0]
            end
        end
    end

    def transition(state)
        if state == 'playing'
            self.class.put("groups/#{self.getPlexGroup}/action", :body => "{\"on\":false, \"transitiontime\":#{$config['hue']['starttransitiontime']}}")
        elsif state == 'paused'
            self.class.put("groups/#{self.getPlexGroup}/action", :body => "{\"on\":true, \"bri\":128, \"transitiontime\":#{$config['hue']['pausedtransitiontime']}}")
        elsif state == 'stopped'
            self.class.put("groups/#{self.getPlexGroup}/action", :body => "{\"on\":true, \"bri\":255, \"transitiontime\":#{$config['hue']['stoptransitiontime']}}")
        end
    end
end
