#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

class Hue
    include HTTParty

    def initialize(config)
        self.class.base_uri "http://#{$config['hue']['hub_ip']}//"
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
end
