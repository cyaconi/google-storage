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
    bucket = attempt_create @bucket_name, nil, true
    attempt_remove bucket
  end

  it "should allow explicit bucket creation" do
    bucket =  attempt_create @bucket_name
    attempt_remove bucket
  end

  it "should be able to specify a pre-defined acl when explicitly creating a bucket" do
    Acl::ALLOWED_ACLS.each do |acl| 
      bucket = attempt_create @bucket_name, acl 
      attempt_remove bucket
    end
    lambda{ attempt_create @bucket_name, 'bad-acl' }.should raise_error
  end

  it "should be able to retrieve a bucket's acl" do
    bucket = attempt_create @bucket_name, nil, true
    acl    = bucket.acl
    acl.should be_an_instance_of Acl
    attempt_remove bucket
  end

  it "should be able to set a bucket's acl" do
    bucket = attempt_create @bucket_name
    acl    = bucket.acl
    acl.add(:scope => :user, :permission => Acl::PERMISSION_READ, :identity => 'bodjiegalang@gmail.com')
    acl.add(:scope => :all_users, :permission => Acl::PERMISSION_READ)
    acl.add(:scope => :all_authenticated_users, :permission => Acl::PERMISSION_WRITE)
    lambda{ bucket.acl = acl }.should_not raise_error
    
    # TODO - make sure new permissions are in the acl
    #bucket = attempt_create @bucket_name, acl, true
    #acl    = bucket.acl
    #acl.include?
    
    attempt_remove bucket
  end
  
  # TODO need to finish implementation
  # TODO delimiter, prefix, etc does not seem to have any effect on the query
  it "should be able to list bucket contents" do
    bucket   = Bucket.new('my-test-bucket', @authorization)
    contents = bucket.contents(:delimiter => '/', :prefix => 'europe/')
    contents.should be_an_instance_of Array
    
    puts ">>>>>>>> #{contents.length}"
    contents.each do |c|
      puts c.inspect
      puts
    end
  end
  
  it "should be able to upload file to bucket" do
    bucket = Bucket.new('my-test-bucket', @authorization)
    path   = "fixtures/man_who_wasnt_there_ver4.jpg"
    key    = File.basename(path)
    lambda{ File.open(path, "r"){ |object| bucket.put(object, key) } }.should_not raise_error
    contents = bucket.contents
    contents.should be_an_instance_of Array
    content = contents.find{ |c| c[:key] =~ /^#{key}$/ }
    content.should_not be nil
    content[:size].should eql File.size(path)
  end

  it "should be able to put an object in a bucket using a string" do
    bucket = Bucket.new('my-test-bucket', @authorization)
    key    = "string-data.txt"
    data   = "lorem ipsum dolor"
    lambda{ bucket.put(data, key) }.should_not raise_error
    contents = bucket.contents
    contents.should be_an_instance_of Array
    content = contents.find{ |c| c[:key] =~ /^#{key}$/ }
    content.should_not be nil
    content[:size].should eql data.length
  end
  
  protected
  def attempt_create(name, acl = nil, autocreate = nil)
    bucket = Bucket.new(name, @authorization, autocreate)
    if autocreate
      bucket.exists?.should be true     
      lambda{ bucket.create(acl) }.should raise_error
    else
      bucket.exists?.should_not be true 
      lambda{ bucket.create(acl) }.should_not raise_error
    end
    bucket.exists?.should be true
    bucket
  end
  
  def attempt_remove(bucket)
    bucket.destroy
    bucket.exists?.should be false
  end
end