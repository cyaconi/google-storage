require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Authorization" do
  before :each do
    @hash_config = config = {
      'id'    => '84fac329bceSAMPLE777d5d22b8SAMPLE77d85ac2SAMPLE2dfcf7c4adf34da46',
      'email' => 'jane@gmail.com',
      'test'         => { 'access-key' => 'GOOGTS7C7FUP3AIRVJTE', 
                          'secret-key' => '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' },
      'production'   => { 'access-key' => 'GOOGTS8C8FUP3AIRVJTE', 
                          'secret-key' => '9abcdef0123456789abcdef0123456789abcdef0123012345678456789abcdef' },
      'development'  => { 'access-key' => 'GOOGTS9C9FUP3AIRVJTE', 
                          'secret-key' => '0123456789a789abcdefbcdef0123456789abcdef0123456789abcdef0123456' }
    }
  end
  
  it "should use the content of the hash as config" do
    compare_authorization_instance(@hash_config, @hash_config)
  end

  it "should use the config file in the current working directory" do
    Dir.chdir "/tmp" do
      path = './google-storage.yml'
      File.write(path, YAML.dump(@hash_config))
      config = YAML.load(File.read './google-storage.yml')
      config.recursively!{ |h| h.symbolize_keys! }
      compare_authorization_instance({}, config)
      File.delete(path)
    end
  end
  
  it "should use the file specified by path as config" do
    path = '/tmp/google-storage.yml'
    File.write(path, YAML.dump(@hash_config))
    config = YAML.load(File.read path)
    config.recursively!{ |h| h.symbolize_keys! }
    compare_authorization_instance(path, config)
  end
  
  it "should not create an empty authorization object when no config is specifed and a default config file does not exist" do
    path = './google-storage.yml'
    File.delete(path) if File.exists? path
    lambda{ Authorization.new('test') }.should raise_error
  end
  
  protected
  def compare_authorization_instance(config, other)
    %w{ test production development }.each do |label|
      authorization = Authorization.new(label, config)
      authorization.should be_an_instance_of Authorization
      keys = authorization.instance_variable_get :@keys
      keys.should eql other[label.to_sym]
    end
  end
end
