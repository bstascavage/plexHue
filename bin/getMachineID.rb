#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

# Class To interact with a Plex server, for getting session statuses
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class MachineID
    include HTTParty

    base_uri "http://localhost:32400/"
    def initialize
        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end
        if !$config['plex']['server'].nil?
            self.class.base_uri "http://#{$config['plex']['server']}:32400//"
        end
    end

    format :xml

    def get(query, args=nil)
        response = self.class.get(query, :verify => false)
        return response
    end

    def getMachineIDs
        sessions = self.class.get('status/sessions')['MediaContainer']

        if sessions['size'].to_i == 1
            session = sessions['Video']
            print "Device: #{session['Player']['title']}\n    user: #{session['User']['title']}\n    machineIdentifier: #{session['Player']['machineIdentifier']}\n\n"
        elsif sessions['size'].to_i > 1
            sessions['Video'].each do | session |
                print "Device: #{session['Player']['title']}\n    user: #{session['User']['title']}\n    machineIdentifier: #{session['Player']['machineIdentifier']}\n\n"
            end
        else
            pp "No sessions found.  Please double-check your config file and make sure your device is playing"
        end
    end
end

machineid = MachineID.new
machineid.getMachineIDs
