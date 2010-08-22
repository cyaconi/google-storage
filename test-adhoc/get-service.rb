#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's GET Service
# http://code.google.com/apis/storage/docs/reference-methods.html#getservice
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# request bucket list
authorization = GoogleStorage::Authorization.new("test")
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Get.new(uri.path)
req["content-length"] = "0"
req["content-type"]   = "application/x-www-form-urlencoded"
req["date"]           = REQUEST_DATE
req["host"]           = "commondatastorage.googleapis.com"
req["user-agent"]     = "Ruby/1.8"
req["authorization"]  = authorization.generate(req)
req.each do |k, v|
  puts "#{k}:\t#{v}"
end
puts

res = Net::HTTP.new(uri.host).start{ |http| http.request(req) }
puts Nokogiri::XML(res.body)


