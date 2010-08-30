require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Acl" do
  before :each do
    @acl = Acl.new(File.read "fixtures/test-acl.xml")
  end
  
  it "should create an ACL object when passed a String representing a valid XML document" do
    @acl.should be_an_instance_of Acl
    @acl.owner.should be_an_instance_of Acl::Owner
    @acl.entries.should_not be_empty
    @acl.length.should eql 4
  end
  
  it "should raise an error when passed a String not representing a valid XML document" do
    lambda{ Acl.new(File.read "fixtures/bad.xml") }.should raise_error
  end

  it "should be possible to add entries" do
    length = @acl.length
    @acl.add(:scope => :user, :identity => "john@gmail.com", :permission => Acl::PERMISSION_FULL_CONTROL)
    @acl.length.should eql length + 1
  end

  it "should not be possible to add duplicate entries" do
    length = @acl.length
    
    @acl.add(:scope => :user, :identity => "john@gmail.com", :permission => Acl::PERMISSION_FULL_CONTROL)
    @acl.length.should eql length + 1
    
    @acl.add(:scope => :user, :identity => "john@gmail.com", :permission => Acl::PERMISSION_READ)
    @acl.length.should eql length + 2
    
    @acl.add(:scope => :user, :identity => "john@gmail.com", :permission => Acl::PERMISSION_READ)
    @acl.length.should eql length + 2
  end
  
  it "should allow removal of entries" do
    length = @acl.length
    @acl.remove(:scope => :user, :identity => "jane@gmail.com", :permission => Acl::PERMISSION_FULL_CONTROL)
    @acl.length.should eql length - 1
  end
end
