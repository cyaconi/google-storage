require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Acl::Owner" do
  before :all do
    @canonical_id = "84fac329bceSAMPLE777d5d22b8SAMPLE77d85ac2SAMPLE2dfcf7c4adf34da46"
    @name         = "Jane Smith"
  end
  
  it "should ensure canonical id is specified when the created" do
    lambda { Acl::Owner.new(:id => "jane.smith@example.com") }.should raise_error
    lambda { Acl::Owner.new(:id => @canonical_id) }.should_not raise_error
    lambda { Acl::Owner.new(:id => @canonical_id, :name => @name) }.should_not raise_error
    lambda { Acl::Owner.new(:name => @name) }.should raise_error
  end
end
