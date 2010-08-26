require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Bucket" do
  before :all do
    @bucket_name   = "test-bucket-20100829"
    @authorization = Authorization.new('test', 'fixtures/google-storage.yml')
  end
  
  it "should create an instance of Bucket" do
    bucket = Bucket.new(@bucket_name, @authorization)
    bucket.should be_an_instance_of Bucket
  end

  it "should allow implicit bucket creation" do
    attempt_bucket_creation @bucket_name, nil, true
  end

  it "should allow explicit bucket creation" do
    attempt_bucket_creation @bucket_name
  end

  it "should be able to specify a pre-defined acl when explicitly creating a bucket" do
    Acl::ALLOWED_ACLS.each{ |acl| attempt_bucket_creation @bucket_name, acl }
  end

  it "should return true or false if the exists? method is used" do
    bucket = Bucket.new(@bucket_name, @authorization, true)
    bucket.exists?.should be true
    attempt_remove bucket
    
    bucket = Bucket.new(@bucket_name, @authorization)
    bucket.exists?.should be false
  end
  
  it "should be able to retrieve a bucket's acl" do
    bucket = Bucket.new(@bucket_name, @authorization, true)
    bucket.exists?.should be true
    
    acl = bucket.acl
    acl.should be_an_instance_of Acl
    
    attempt_remove bucket
  end

  it "should be able to set a bucket's acl" do
    # TODO
  end
  
  protected
  def attempt_bucket_creation(name, acl = nil, autocreate = nil)
    bucket = Bucket.new(name, @authorization, autocreate)
    if autocreate
      bucket.exists?.should be true     
      lambda{ bucket.create(acl) }.should raise_error
    else
      bucket.exists?.should_not be true 
      lambda{ bucket.create(acl) }.should_not raise_error
    end
    bucket.exists?.should be true
    attempt_remove bucket
  end
  
  def attempt_remove(bucket)
    bucket.delete
    bucket.exists?.should be false
  end
end