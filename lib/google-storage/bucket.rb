module GoogleStorage
  class Bucket < RequestMethods
    attr_reader :name
    attr_reader :authorization
    attr :acl
    
    def initialize(name, authorization)
      @name          = name
      @authorization = authorization
    end

    def open
      doc  = exec :get, :path => @name, :acl => true
      @acl = Acl.new(doc)
      self
    end

    def self.open(name, authorization)
      bucket = Bucket.new(name, authorization)
      bucket.open
    end

    def acl= acl
      exec :put, :path => @name, :acl => true, :body => acl.to_s
      @acl = acl
    end
    
    # create a new bucket and optionally assign an acl.
    # if an acl is specified, an exception is raised if it not one of:
    # - Acl::PRIVATE or private
    # - Acl::PUBLIC_READ or public-read
    # - Acl::PUBLIC_READ_WRITE or public-read-write
    # - Acl::AUTHENTICATED_READ or authenticated-read
    # - Acl::BUCKET_OWNER_READ or bucket-owner-read
    # - Acl::BUCKET_OWNER_FULL_CONTROL or bucket-owner-full-control
    def create(acl = nil)
      raise ArgumentError, "Not a valid acl" \
        unless acl.nil? or Acl::ALLOWED_ACLS.include? acl.to_s
      options                = { :path => @name }
      options[:'x-goog-acl'] = acl.to_s unless acl.nil?
      exec :put, options
      open
    end
    
    def self.create(name, authorization, acl = nil)
      bucket = Bucket.new(name, authorization)
      bucket.create(acl)
    end

    def delete
      exec :delete, :path => @name
    end
    
    def self.delete(name, authorization)
      bucket = Bucket.new(name, authorization)
      bucket.delete
    end
    
    # list the objects in a bucket
    def objects(options = { })
      doc = exec :get, :path => @name, :params => options
      normalize = lambda do |k, v| 
        case k
        when 'last_modified' then DateTime.parse(v)
        when 'size'          then v.to_i
        when 'e_tag'         then v.sub(/"/, '')
        when 'owner'         then Acl::Owner.new(v)
        else v
        end
      end
      #doc.xpath("//xmlns:CommonPrefixes/Prefix").map{ |node| node.text }
      #doc.xpath("//xmlns:IsTruncated").text =~ /^true$/i
      doc.xpath("//xmlns:Contents").map{ |node| node.to_h(&normalize) }
    end
    
    # returns an Object from this bucket given its path; valid keys for the 
    # options parameter are:
    # - if-match	
    # - if-modified-since	
    # - if-none-match
    # - if-unmodified-since
    # - range
    #
    # read http://code.google.com/apis/storage/docs/reference-methods.html#getobject
    # for details.
    def [] path, options = {}
      obj = Object.new(self, path)
      obj.download options
    end
  end
end