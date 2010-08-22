#!/usr/bin/env ruby

require 'google-storage'

include GoogleStorage

# 
puts Acl::Entry.UserById(ACL_PERMISSION_FULL_CONTROL, :id => '84fac329bceSAMPLE777d5d22b8SAMPLE77d85ac2SAMPLE2dfcf7c4adf34da46')
puts Acl::Entry.UserByEmail(ACL_PERMISSION_FULL_CONTROL, :email => 'jurisgalang@gmail.com')
puts Acl::Entry.GroupByDomain(ACL_PERMISSION_FULL_CONTROL, :domain => 'jurisgalang.com')
puts Acl::Entry.GroupByEmail(ACL_PERMISSION_FULL_CONTROL, :email => 'jurisgalang@gmail.com')
puts Acl::Entry.GroupById(ACL_PERMISSION_FULL_CONTROL, :id => '84fac329bceSAMPLE777d5d22b8SAMPLE77d85ac2SAMPLE2dfcf7c4adf34da46')
puts Acl::Entry.AllUsers(ACL_PERMISSION_FULL_CONTROL)
puts Acl::Entry.AllAuthenticatedUsers(ACL_PERMISSION_FULL_CONTROL)

#
puts Acl::Entry.parse(:scope => :group, :permission => ACL_PERMISSION_FULL_CONTROL, :identity =>  'jurisgalang@gmail.com', :name => 'Juris Galang')
puts Acl::Entry.parse(:scope => :user, :permission => ACL_PERMISSION_FULL_CONTROL, :identity =>  'jurisgalang@gmail.com', :name => 'Juris Galang')
puts Acl::Entry.parse(:scope => :group, :permission => ACL_PERMISSION_FULL_CONTROL, :identity =>  'jurisgalang.com', :name => 'Juris Galang')

#
entry = Acl::Entry.UserByEmail(ACL_PERMISSION_FULL_CONTROL, :email => 'jurisgalang@gmail.com')
puts entry.is?(:scope => :user, :permission => ACL_PERMISSION_FULL_CONTROL, :identity => 'jurisgalang@gmail.com', :name => 'Juris Galang')
