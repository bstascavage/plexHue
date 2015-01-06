#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

class Hue
    include HTTParty

    def initialize(config)
        self.class.base_uri "http://#{$config['hue']['hub_ip']}/api/newdeveloper//"
    end

    format :json

    def get(query, args=nil)
        response = self.class.get(query, :verify => false)
        return response
    end

    def put(query, body)
        response = self.class.put(query, :body => body )
        return response
    end

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
end
