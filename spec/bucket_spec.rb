require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Bucket" do
  before :each do
    config = Configuration.new('fixtures/google-storage.yml')
    @credentials = config.credentials :development
    @bucket      = Bucket.new('jurisgalang', @credentials)
  end

  it "should return an instance of object and its metadata attributes populated" do
    lambda{ @object = @bucket['lorem-ipsum.txt'] }.should_not raise_error    
    @object.should be_an_instance_of GoogleStorage::Object
    %w{ x_frame_options etag expires content_type content_length
        server date cache_control x_content_type_options 
        x_xss_protection last_modified pragma }.each do |attr|
      @object.should respond_to :"#{attr}"
      @object.content.should be nil
    end
  end
  
  it "should create an instance of Bucket" do
    @credentials.should be_an_instance_of Credentials
    @bucket.should be_an_instance_of Bucket
  end
  
  it "should list all of the objects that are in the bucket" do
    lambda{ @bucket.objects }.should_not raise_error
    objects = @bucket.objects
    objects.should be_an_instance_of Array
    objects.length.should eql 9
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
    lambda{ @bucket = Bucket.create('jurisgalang-test-create', @credentials, 'public-read-write') }.should_not raise_error
    @bucket.should be_an_instance_of Bucket
    # TODO: verify that a bucket named jurisgalang-test-create exists
    lambda{ @bucket.destroy! }.should_not raise_error
    # TODO: verify that a bucket named jurisgalang-test-create no longer exists
  end
  
  it "should be able to set a bucket's acl" do
    @bucket = Bucket.create('jurisgalang-test-create', @credentials, 'public-read-write')
    acl     = @bucket.acl
    acl.add(:scope => :user, :permission => Acl::PERMISSION_READ, :identity => 'bodjiegalang@gmail.com')
    acl.add(:scope => :all_users, :permission => Acl::PERMISSION_READ)
    acl.add(:scope => :all_authenticated_users, :permission => Acl::PERMISSION_WRITE)
    lambda{ @bucket.acl = acl }.should_not raise_error
    # TODO: need to verify that the new permissions are in the acl
    lambda{ @bucket.destroy! }.should_not raise_error
  end
  
  it "should be able to download an object" do
    lambda{ @object = @bucket.download 'lorem-ipsum.txt' }.should_not raise_error
    @object.should be_an_instance_of GoogleStorage::Object
    @object.path.should eql 'lorem-ipsum.txt'
  end
  
  it "should be able to download an object and save it locally" do
    lambda{ @object = @bucket.download 'lorem-ipsum.txt', :dest => "/tmp", :overwrite => true }.should_not raise_error
    @object.should be_an_instance_of GoogleStorage::Object
    @object.path.should eql 'lorem-ipsum.txt'
    File.exists?("/tmp/lorem-ipsum.txt").should eql true
    File.size("/tmp/lorem-ipsum.txt").should eql @object.content.length
    lambda{ @object = @bucket.download 'lorem-ipsum.txt', :dest => "/tmp" }.should raise_error
    File.delete "/tmp/lorem-ipsum.txt"
  end
  
  it "should be able to download an object and save it locally using a different filename" do
    lambda{ @object = @bucket.download 'lorem-ipsum.txt', :dest => "/tmp/file.txt", :overwrite => true }.should_not raise_error
    File.exists?("/tmp/file.txt").should eql true
    File.size("/tmp/file.txt").should eql @object.content.length
    lambda{ @object = @bucket.download 'lorem-ipsum.txt', :dest => "/tmp/file.txt" }.should raise_error
    File.delete "/tmp/file.txt"
  end
  
  it "should be able to upload/create and delete an object" do
    lambda{ @object = @bucket.upload 'lorem ipsum dolor', :dest => "upload-test.txt" }.should_not raise_error
    @object.should be_an_instance_of GoogleStorage::Object
    @object.path.should eql 'upload-test.txt'
    lambda{ @object.destroy! }.should_not raise_error
  end
  
  it "should copy object from another bucket" do
    lambda{ @dest = Bucket.create('jurisgalang-test-create', @credentials, 'public-read-write') }.should_not raise_error
    @dest.should be_an_instance_of Bucket
    lambda{ @object = @dest.copy "jurisgalang/lorem-ipsum.txt" }.should_not raise_error
    @object.should be_an_instance_of GoogleStorage::Object
    @object.path.should eql 'lorem-ipsum.txt'
    lambda{ @object.destroy! }.should_not raise_error
    lambda{ @dest.destroy! }.should_not raise_error
  end
  
  it "should raise error when using destroy! to delete a non-existent bucket" do
    # TODO
  end
  
  it "should not raise error when using destroy to delete a non-existent bucket" do
    # TODO
  end
  
  it "should be able to create a folder" do
    lambda{ @object = @bucket.mkdir 'private/folder' }.should_not raise_error
    @object.folder?.should eql true
  end

  it "should be able to delete a folder" do
    lambda{ @result = @bucket.rmdir 'private/folder' }.should_not raise_error
    @result.should eql true
    
    lambda{ @result = @bucket.rmdir 'private/folder' }.should_not raise_error
    @result.should eql false

    lambda{ @result = @bucket.rmdir! 'private/folder' }.should raise_error
  end
end