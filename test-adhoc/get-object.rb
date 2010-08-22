#!/usr/bin/env ruby

# 
# Test implementation of Google Storage's GET Object
# https://code.google.com/apis/storage/docs/reference-methods.html#getobject
#
require 'google-storage'
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

# download an object
uri = URI.parse('http://commondatastorage.googleapis.com/')
#req = Net::HTTP::Get.new('/kreekt-bucket-2/8c6eae41_PamploGP08.jpg')
req = Net::HTTP::Get.new('/kreekt-bucket-2/folder-1/test.txt')
#req = Net::HTTP::Get.new('/kreekt-bucket-3/folder-1_$folder$')
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
  puts "path: #{req.path}"
  puts res.body
  #File.write(File.basename(req.path), res.body)
else
  puts Nokogiri::XML(res.body) 
end

puts "-" * 40

# request an object's acl
uri = URI.parse('http://commondatastorage.googleapis.com/')
req = Net::HTTP::Get.new('/kreekt-bucket-2/folder-1/test.txt?acl')
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
