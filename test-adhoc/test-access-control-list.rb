#!/usr/bin/env ruby

require 'google-storage'

acl = GoogleStorage::AccessControlList.new(File.read "fixtures/acl.xml")
puts acl
puts "owner.id: " + acl.owner.canonical_id
puts "owner.name: " + acl.owner.name
puts "entries:"
acl.each do |entry|
  puts "- #{entry.to_s}"
end
puts
puts acl.add(:scope => :user, :permission => GoogleStorage::ACL_PERMISSION_FULL_CONTROL, :identity => 'jurisgalang@gmail.com', :name => 'Juris Galang')
puts acl.add(:scope => :user, :permission => GoogleStorage::ACL_PERMISSION_FULL_CONTROL, :identity => 'jurisgalang@gmail.com', :name => 'Juris Galang')
puts acl.add(:scope => :user, :permission => GoogleStorage::ACL_PERMISSION_FULL_CONTROL, :identity => 'jurisgalang@gmail.com', :name => 'Juris Galang')
puts acl.add(:scope => :user, :permission => GoogleStorage::ACL_PERMISSION_FULL_CONTROL, :identity => 'jurisgalang@gmail.com', :name => 'Juris Galang')
puts
#puts acl.to_xml
acl.each do |entry|
  puts "- #{entry.to_s}"
end
puts

puts acl.add(:scope => :all_users, :permission => GoogleStorage::ACL_PERMISSION_FULL_CONTROL)
puts acl.add(:scope => :all_authenticated_users, :permission => GoogleStorage::ACL_PERMISSION_FULL_CONTROL)
puts acl.to_xml
