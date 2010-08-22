#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's GET Bucket
# https://code.google.com/apis/storage/docs/reference-methods.html#getbucket
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# request bucket content
authorization = GoogleStorage::Authorization.new("test")
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Get.new('/kreekt-bucket-2/?delimiter=/&prefix=folder-1/')
req["content-length"] = "0"
req["content-type"]   = "application/x-www-form-urlencoded"
req["date"]           = REQUEST_DATE
req["user-agent"]     = "Ruby/1.8"
req["host"]           = uri.host
req["authorization"]  = authorization.generate(req)
req.each do |k, v|
  puts "#{k}:\t#{v}"
end
puts

res = Net::HTTP.new(uri.host).start{ |http| http.request(req) }
puts Nokogiri::XML(res.body)

puts "-" * 40

# request bucket acl
authorization = GoogleStorage::Authorization.new("test")
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Get.new('/kreekt-bucket-2/?acl')
req["content-length"] = "0"
req["content-type"]   = "application/x-www-form-urlencoded"
req["date"]           = REQUEST_DATE
req["user-agent"]     = "Ruby/1.8"
req["host"]           = uri.host
req["authorization"]  = authorization.generate(req)
req.each do |k, v|
  puts "#{k}:\t#{v}"
end
puts

res = Net::HTTP.new(uri.host).start{ |http| http.request(req) }
puts Nokogiri::XML(res.body)
