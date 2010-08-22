#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's PUT Bucket
# http://code.google.com/apis/storage/docs/reference-methods.html#putbucket
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# create bucket with default acl
authorization = GoogleStorage::Authorization.new("test")
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Put.new('/kreekt-bucket-6/')
req["content-length"] = "0"
req["content-type"]   = "application/x-www-form-urlencoded"
req["date"]           = REQUEST_DATE
req["x-goog-acl"]     = "bucket-owner-full-control"
req["user-agent"]     = "Ruby/1.8"
req["host"]           = uri.host
req["authorization"]  = authorization.generate(req)
req.each do |k, v|
  puts "#{k}:\t#{v}"
end
puts

res = Net::HTTP.new(uri.host).start{ |http| http.request(req) }
puts Nokogiri::XML(res.body)
