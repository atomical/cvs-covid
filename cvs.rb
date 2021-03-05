#!/usr/bin/env ruby

require "dotenv"
require "open-uri"
require "json"
require "terminal-notifier"

Dotenv.load

STATE = ENV.fetch("STATE")
URL = "https://www.cvs.com/immunizations/covid-19-vaccine.vaccine-status.#{STATE}.json?vaccineinfo"
REFERRER = "https://www.cvs.com/immunizations/covid-19-vaccine"

puts "Starting CVS COVID vaccine checker"
puts ""

TerminalNotifier.notify("Starting!")

while true do
  puts "Checking at #{Time.now}"

  open(URL, "Referer" => REFERRER) do |f|
    payload = JSON.parse(f.read)
    locations = payload["responsePayloadData"]["data"][STATE]
    puts "Locations reported: #{locations.size}"

    available = locations.select { |location| location["status"] !~ /booked/i }

    if available.any?
      cities = available.map { |location| "#{location["city"]} (#{location["status"]}, #{location["totalAvailable"]} available)" }

      puts "Availabilities!"
      puts cities

      TerminalNotifier.notify("Availabilities!")
      exit(0)

    else
      puts "Nothing found :("
    end
  end

  puts "-----\n"
  sleep 10
end
