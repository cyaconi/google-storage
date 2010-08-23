require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Service" do
  before :each do
    @authorization = Authorization.new('test', 'fixtures/google-storage.yml')
    @service       = Service.new(@acl)
  end
  
  it "should create an instance of Service" do
    @service.should be_an_instance_of Service
  end

  it "should list all of the buckets that are owned by the requester" do
    flunk "--- NOT IMPLEMENTED ---"
  end

  it "should be able to retrieve a bucket by name if the bucket exists" do
    flunk "--- NOT IMPLEMENTED ---"
  end

  it "should not be able to retrieve a bucket if the bucket does not exist" do
    flunk "--- NOT IMPLEMENTED ---"
  end

  it "should be able to automatically create a bucket if the bucket it does not exist" do
    flunk "--- NOT IMPLEMENTED ---"
  end

  it "should accept a block that allows the client to communicate with the Service" do
    flunk "--- NOT IMPLEMENTED ---"
    #Service.new(@acl) do 
    #  buckets.should blah
    #  bkt = fetch 'google-storage-gem-test-bucket-9fac50aacc069b716cc84ae56a5a1f27'
    #  bkt.should blah
    #end
  end
end