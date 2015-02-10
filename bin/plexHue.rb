#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'bundler/setup'
require 'httparty'
require 'logger'
require 'optparse'

require_relative 'plex'
require_relative 'hue'

class PlexHue
 $options = {
        :verbose         => false
    }

    OptionParser.new do |opts|
        opts.banner = "PlexHue: a script for syncingyour lights with your Plex video playback\nUsage: plexHue.rb [$options]"

        opts.on("-v", "--verbose", "Enable verbose debug logging") do |opt|
            $options[:verbose] = true
        end
    end.parse!

    def initialize
        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end

        begin
            $logging_path = File.join(File.expand_path(File.dirname(__FILE__)), '../plexHue.log') 
            $logger = Logger.new($logging_path)
            
            if $options[:verbose]
                $logger.level = Logger::DEBUG
            else
                $logger.level = Logger::INFO
            end
        rescue
            abort('Log file not found.  Exiting...')
        end

        $logger.info("Starting up PlexHue")
    end

    def main
        hue = Hue.new($config)
        plex = Plex.new($config)
        $state = 'stopped'
        $pauseTime = 0

        hue.deleteGroup
        hue.createGroup

        while    
            nowPlaying = plex.get('status/sessions')['MediaContainer']
            isPlaying = false

            if nowPlaying['size'].to_i == 1
                client = nowPlaying['Video']
                if client['Player']['machineIdentifier'].empty?
                    client['Player']['machineIdentifier'] = ''
                end

                if client['Player']['machineIdentifier'] == $config['plex']['machineIdentifier']
                    if client['Player']['state'] == 'playing'
                        $pauseTime = 0
                        isPlaying = true

                        if $state != 'playing'
                            $state = 'playing'
                            $logger.info("Video has started.  Dimming lights")
                            hue.transition($state)
                        end
                    elsif client['Player']['state'] == 'paused'
                        if $pauseTime == 0
                            $pauseTime = Time.now
                        end

                        if (Time.now - $pauseTime) > 3
                            isPlaying = true

                            if $state != 'paused'
                                $state = 'paused'
                                $logger.info("Video is paused.  Restoring lights")
                                hue.transition($state)
                            end
                        end
                     end
                 end
            elsif nowPlaying['size'].to_i > 1
                nowPlaying['Video'].each do | client | 
                    if client['Player']['machineIdentifier'].empty?
                        client['Player']['machineIdentifier'] = ''
                    end

                    if client['Player']['machineIdentifier'] == $config['plex']['machineIdentifier']
                        if client['Player']['state'] == 'playing'
                            $pauseTime = 0
                            isPlaying = true

                            if $state != 'playing'
                                $state = 'playing'
                                $logger.info("Video has started.  Dimming lights")
                                hue.transition($state)
                            end
                        elsif client['Player']['state'] == 'paused'
                            if $pauseTime == 0
                                $pauseTime = Time.now
                            end

                            if (Time.now - $pauseTime) > 3
                                isPlaying = true

                                if $state != 'paused'
                                    $state = 'paused'
                                    $logger.info("Video is paused.  Restoring lights")
                                    hue.transition($state)
                                end
                            end
                        end
                    end
                end
            end
            if (!isPlaying && $state != 'stopped')
                $state = 'stopped'
                isPlaying = false

                sleep 2
                $logger.info("Video is stopped.  Turning lights back on")
                hue.transition($state)
            end
            
            sleep 0.2
        end
    end
end

plexHue = PlexHue.new
plexHue.main
