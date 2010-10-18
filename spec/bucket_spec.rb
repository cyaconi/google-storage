require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Bucket" do
  before :each do
    @authorization = Authorization.new('development', 'fixtures/google-storage.yml')
    @bucket        = Bucket.new('jurisgalang', @authorization)
  end
  
  it "should create an instance of Bucket" do
    @authorization.should be_an_instance_of Authorization
    @bucket.should be_an_instance_of Bucket
  end

  it "should list all of the objects that are in the bucket" do
    lambda{ @bucket.objects }.should_not raise_error
    bucket = @bucket.objects
    bucket.should be_an_instance_of Array
    bucket.length.should eql 9
  end

  it "should enforce parameters when listing the contents of a bucket" do
    lambda{ @bucket.objects }.should_not raise_error
    
    africa = @bucket.objects(:prefix => "africa")
    africa.should be_an_instance_of Array
    africa.length.should eql 2

    france = @bucket.objects(:prefix => "europe/france")
    france.should be_an_instance_of Array
    france.length.should eql 2

    germany = @bucket.objects(:prefix => "europe/germany")
    germany.should be_an_instance_of Array
    germany.length.should eql 2

    sweden = @bucket.objects(:prefix => "europe/sweden")
    sweden.should be_an_instance_of Array
    sweden.length.should eql 1
    
    bucket = @bucket.objects(:'max-keys' => 3)
    bucket.should be_an_instance_of Array
    bucket.length.should eql 3
    
    # TODO: test for delimiter
    # TODO: test for marker
  end
  
  it "should be able to create and delete a bucket" do
    lambda{ @bucket = Bucket.create('jurisgalang-test-create', @authorization, 'public-read-write') }.should_not raise_error
    @bucket.should be_an_instance_of Bucket
    # TODO: verify that a bucket named jurisgalang-test-create exists
    
    lambda{ @bucket.destroy }.should_not raise_error
    # TODO: verify that a bucket named jurisgalang-test-create no longer exists
  end
  
  it "should be able to set a bucket's acl" do
    @bucket = Bucket.create('jurisgalang-test-create', @authorization, 'public-read-write')
    acl     = @bucket.acl
    acl.add(:scope => :user, :permission => Acl::PERMISSION_READ, :identity => 'bodjiegalang@gmail.com')
    acl.add(:scope => :all_users, :permission => Acl::PERMISSION_READ)
    acl.add(:scope => :all_authenticated_users, :permission => Acl::PERMISSION_WRITE)
    lambda{ @bucket.acl = acl }.should_not raise_error
  
    # TODO: need to verify that the new permissions are in the acl
    @bucket.destroy
  end
  
  it "should be able to download an object" do
    lambda{ @object = @bucket.download 'lorem-ipsum.txt' }.should_not raise_error
    @object.should be_an_instance_of GoogleStorage::Object
    @object.path.should eql 'lorem-ipsum.txt'
    
    ## TODO: verify contents of object
    #
    #lambda{ @object = @bucket['lipskryx.jpg'] }.should_not raise_error
    #@object.fullpath
    #@object.content_length
    #@object.date
    #@object.last_modified
    ## TODO: verify contents of object
    #
    #lambda{ @bucket['non-existent-file'] }.should raise_error
  end
end