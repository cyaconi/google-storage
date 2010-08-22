#!/usr/bin/env ruby

require 'google-storage'

authorization = GoogleStorage::Authorization.new("test")
service       = GoogleStorage::Service.new(authorization)
puts service.buckets.inspect


