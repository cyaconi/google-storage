require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Service" do
  before :each do
    config = Configuration.new('fixtures/google-storage.yml')
    @credentials = config.credentials :development
    @service       = Service.new(@credentials)
  end
  
  it "should create an instance of Service" do
    @credentials.should be_an_instance_of Credentials
    @service.should be_an_instance_of Service
  end

  it "should list all of the buckets that are owned by the requester" do
    lambda{ @service.buckets }.should_not raise_error
    @service.buckets.should be_an_instance_of Array
  end

  it "should open a bucket" do
    lambda{ @bucket = @service[:jurisgalang] }.should_not raise_error
    @bucket.should be_an_instance_of Bucket
    @bucket.acl.should be_an_instance_of Acl
  end
end