#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's DELETE Bucket
# https://code.google.com/apis/storage/docs/reference-methods.html#deletebucket
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# delete bucket
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Delete.new('/kreekt-bucket-4/')
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
puts Nokogiri::XML(res.body)
