require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include GoogleStorage

describe "Acl::Entry" do
  before :all do
    @canonical_id  = "84fac329bceSAMPLE777d5d22b8SAMPLE77d85ac2SAMPLE2dfcf7c4adf34da46"
    @name          = "Jane Smith"
    @email_address = "jane.smith@example.com"
    @domain_name   = "example.com"
  end
  
  it "should ensure canonical id is specified when using the *ById class method" do
    %w{ Group User }.each do |scope|
      lambda { Acl::Entry.send(:"#{scope}ById", Acl::PERMISSION_READ, :id => @canonical_id) }.should_not raise_error
      lambda { Acl::Entry.send(:"#{scope}ById", Acl::PERMISSION_READ, :id => @email_address) }.should raise_error
    end
  end

  it "should ensure email address is specified when using the *ByEmail class method" do
    %w{ Group User }.each do |scope|
      [ :email, :email_address ].each do |identifier|
        lambda { Acl::Entry.send(:"#{scope}ByEmail", Acl::PERMISSION_READ, identifier => @email_address) }.should_not \
          raise_error
        lambda { Acl::Entry.send(:"#{scope}ByEmail", Acl::PERMISSION_READ, identifier => @domain_name) }.should raise_error
        lambda { Acl::Entry.send(:"#{scope}ByEmail", Acl::PERMISSION_READ, identifier => @domain_name) }.should raise_error
      end
    end
  end

  it "should ensure domain name is specified when using the *ByDomain class method" do
    lambda { Acl::Entry.GroupByDomain(Acl::PERMISSION_READ, :domain => @domain_name) }.should_not raise_error
    lambda { Acl::Entry.GroupByDomain(Acl::PERMISSION_READ, :domain => @email_address) }.should raise_error
    lambda { Acl::Entry.GroupByDomain(Acl::PERMISSION_READ, :domain => @canonical_id) }.should raise_error
  end

  it "should ensure the correct attribute values for *ById" do
    %w{ Group User }.each do |scope|
      entry = Acl::Entry.send(:"#{scope}ById", Acl::PERMISSION_READ, :id => @canonical_id)
      entry.should respond_to :canonical_id
      entry.identity.should match entry.canonical_id
      entry.scope.should match "#{scope}ById"
      entry.permission.should match Acl::PERMISSION_READ
      entry.name.should be_blank

      entry = Acl::Entry.send(:"#{scope}ById", Acl::PERMISSION_WRITE, :id => @canonical_id, :name => @name)
      entry.permission.should match Acl::PERMISSION_WRITE
      entry.name.should match @name

      entry = Acl::Entry.send(:"#{scope}ById", Acl::PERMISSION_FULL_CONTROL, :id => @canonical_id)
      entry.permission.should match Acl::PERMISSION_FULL_CONTROL
    end
  end

  it "should ensure the correct attribute values for *ByEmail" do
    %w{ Group User }.each do |scope|
      [ :email, :email_address ].each do |identifier|
        entry = Acl::Entry.send(:"#{scope}ByEmail", Acl::PERMISSION_READ, identifier => @email_address)
        entry.should respond_to :email_address
        entry.identity.should match entry.email_address
        entry.scope.should match "#{scope}ByEmail"
        entry.permission.should match Acl::PERMISSION_READ
        entry.name.should be_blank

        entry = Acl::Entry.send(:"#{scope}ByEmail", Acl::PERMISSION_WRITE, identifier => @email_address, :name => @name)
        entry.permission.should match Acl::PERMISSION_WRITE
        entry.name.should match @name

        entry = Acl::Entry.send(:"#{scope}ByEmail", Acl::PERMISSION_FULL_CONTROL, identifier => @email_address)
        entry.permission.should match Acl::PERMISSION_FULL_CONTROL
      end
    end
  end
end
