require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Service" do
  before :each do
    @bucket_name   = "test-bucket-20100829"
    @authorization = Authorization.new('test', 'fixtures/google-storage.yml')
    @service       = Service.new(@authorization)
  end
  
  it "should create an instance of Service" do
    @authorization.should be_an_instance_of Authorization
    @service.should be_an_instance_of Service
  end

  it "should list all of the buckets that are owned by the requester" do
    lambda{ @service.buckets }.should_not raise_error
    @service.buckets.should be_an_instance_of Array
  end

  it "should not be able to retrieve a bucket if the bucket does not exist" do
    bkt = @service.get(@bucket_name)
    bkt.should be nil
  end

  it "should be able to automatically create a bucket if the bucket does not exist" do
    bkt = @service.get(@bucket_name, true)
    bkt.should_not be nil
    bkt.name.should match @bucket_name
    @service.buckets.length.should eql 1
    bkt.delete
    @service.buckets.length.should eql 0
  end

  it "should accept a block that allows the client to communicate with the Service" do
    bucket_name = @bucket_name
    @sevice = Service.new(@authorization) do 
      buckets
      get(bucket_name)
      bkt = get(bucket_name, true)
      bkt.delete
    end
    @service.should be_an_instance_of Service
  end
end