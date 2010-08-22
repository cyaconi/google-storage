require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Authorization" do
  before :all do
    @hash_config = config = {
      'id'    => '84fac329bceSAMPLE777d5d22b8SAMPLE77d85ac2SAMPLE2dfcf7c4adf34da46',
      'email' => 'jane@gmail.com',
      'test'         => { 'access_key' => 'GOOGTS7C7FUP3AIRVJTE', 
                          'secret_key' => '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' },
      'production'   => { 'access_key' => 'GOOGTS8C8FUP3AIRVJTE', 
                          'secret_key' => '9abcdef0123456789abcdef0123456789abcdef0123012345678456789abcdef' },
      'development'  => { 'access_key' => 'GOOGTS9C9FUP3AIRVJTE', 
                          'secret_key' => '0123456789a789abcdefbcdef0123456789abcdef0123456789abcdef0123456' }
    }
    
    @config_path = '/tmp/google-storage.yml'
    File.write(@config_path, YAML.dump(@hash_config))

    @default_config = YAML.load(File.read 'google-storage.yml')
    @default_config.recursively!{ |h| h.symbolize_keys! }
  end
  
  it "should use the config file in the current working directory" do
    compare_authorization_instance({}, @default_config)
  end
  
  it "should use the content of the hash as config" do
    compare_authorization_instance(@hash_config, @hash_config)
  end

  it "should use the file specified by path as config" do
    config = YAML.load(File.read @config_path)
    config.recursively!{ |h| h.symbolize_keys! }
    compare_authorization_instance(@config_path, config)
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