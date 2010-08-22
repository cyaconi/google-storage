#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's PUT Object
# https://code.google.com/apis/storage/docs/reference-methods.html#putobject
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# the file/object to put
#filename = 'notes.txt'
filename = 'fixtures/man_who_wasnt_there_ver4.jpg'
#filename = 'fixtures/trailer01.mov'
#data = File.read(filename)

# put object with pre-defined acl
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Put.new("/kreekt-bucket-5/#{filename}")
req["content-length"]            = File.size(filename) #data.length
req["content-type"]              = MimeType.of(filename)
req["date"]                      = REQUEST_DATE
req["x-goog-acl"]                = "bucket-owner-full-control"
req["x-goog-metadata-directive"] = "COPY"
req["user-agent"]                = "Ruby/1.8"
req["host"]                      = uri.host
req["authorization"]             = GoogleStorage::Authorization.new.generate(req)
req.each do |k, v|
  puts "#{k}:\t#{v}"
end
puts

stream          = File.open(filename, "r")
req.body_stream = stream
res = Net::HTTP.new(uri.host).start{ |http| http.request(req) }
stream.close
#res = Net::HTTP.new(uri.host).start{ |http| http.request(req, data) }
puts Nokogiri::XML(res.body)
