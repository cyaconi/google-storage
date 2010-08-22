#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's HEAD Object
# https://code.google.com/apis/storage/docs/reference-methods.html#headobject
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# list object metadata
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Head.new('/kreekt-bucket-1/8c6eae41_PamploGP04.jpg')
req["content-length"] = "0"
req["content-type"]   = "application/x-www-form-urlencoded"
req["date"]           = REQUEST_DATE
req["user-agent"]     = "Ruby/1.8"
req["host"]           = uri.host
req["authorization"]  = GoogleStorage::Authorization.new.generate(req)
req.each do |k, v|
  puts "#{k}:\t#{v}"
end
puts

res = Net::HTTP.new(uri.host).start{ |http| http.request(req) }
if res.instance_of? Net::HTTPOK
  res.each do |k, v|
    puts "#{k}:\t#{v}"
  end
else
  puts res
end
