#!/usr/bin/env ruby

require 'google-storage'

puts "test: create bucket"
authorization = GoogleStorage::Authorization.new("test")
bucket        = GoogleStorage::Bucket.new("jurisgalang-bucket-2", authorization, true)
puts

puts "test: get acl"
puts "id: #{bucket.acl.owner.canonical_id} " 
puts "name: #{bucket.acl.owner.name}" 
bucket.acl.each do |entry|
  puts "scope: #{entry.scope}"
  puts "perm: #{entry.permission}"
  puts "name: #{entry.name}" 
  puts "uid: #{entry.canonical_id}"
end
puts

puts "test: acl.to_xml"
puts bucket.acl.to_xml
puts 

puts "test: set acl"
acl = bucket.acl
acl.add(:scope => :user, :permission => GoogleStorage::ACL_PERMISSION_READ, :identity => 'bodjiegalang@gmail.com')
acl.add(:scope => :all_users, :permission => GoogleStorage::ACL_PERMISSION_READ)
acl.add(:scope => :all_authenticated_users, :permission => GoogleStorage::ACL_PERMISSION_WRITE)
bucket.acl = acl
puts bucket.acl.to_xml
puts 

puts "test: delete bucket"
bucket.delete

