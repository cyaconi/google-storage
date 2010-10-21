module GoogleStorage
  class Bucket < RequestMethods
    attr_reader :name
    attr_reader :authorization
    attr :acl
    
    def initialize name, authorization
      @name          = name
      @authorization = authorization
    end

    def open &block
      doc  = exec :get, :path => @name, :acl => true
      @acl = Acl.new(doc)
      instance_eval &block if block_given?
      self
    end

    def self.open name, authorization, &block
      bucket = Bucket.new(name, authorization)
      bucket.open &block
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
    def create acl = nil, &block
      raise ArgumentError, "Not a valid acl" \
        unless acl.nil? or Acl::ALLOWED_ACLS.include? acl.to_s
      options = { :path => @name }
      options[:'x-goog-acl'] = acl.to_s unless acl.nil?
      exec :put, options
      open &block
    end
    
    def self.create name, authorization, acl = nil, &block
      bucket = Bucket.new(name, authorization)
      bucket.create acl, &block
    end

    def destroy
      destroy!
      true
    rescue BucketAlreadyOwnedByYouException, # 409 Conflict
      BucketNameUnavailableException,
      BucketNotEmptyException, 
      OperationAbortedException, 
      AccessDeniedException,                 # 404 Not Found
      NoSuchBucketException, 
      NoSuchKeyException
      false
    end

    def destroy!
      exec :delete, :path => @name
    end
    
    def self.destroy name, authorization
      bucket = Bucket.new(name, authorization)
      bucket.destroy
    end
    
    # list the objects in a bucket
    def objects options = { }
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
    
    # download an object from this bucket and returns and Object if the object
    # was successfully downloaded. otherwise nil.
    #
    # if dest is specified, the content is saved into a local file. if dest 
    # resolves to a file, and overwite is true then an IOError is raised. if
    # dest resolves to a directory, then the content of the object is saved 
    # to a file matching the name of the object. if dest is meant to be 
    # directory but it does not exist then  an IOError is raised.
    #
    # valid keys for the options parameter are:
    # - if-match	
    # - if-modified-since	
    # - if-none-match
    # - if-unmodified-since
    # - range
    #
    # read http://code.google.com/apis/storage/docs/reference-methods.html#getobject
    # for details.
    def download src, options = { }
      dest      = options.delete(:dest)
      overwrite = options.delete(:overwrite)
      GoogleStorage::Object.new(self, src) do
        get options
        save dest, overwrite unless dest.nil?
      end
    rescue NotModifiedException, PreconditionFailedException
    end
    
    def delete path
      obj = Object.new(self, path)
      obj.destroy
    end

    # uploads an object into this bucket
    def upload src, options = { }
      path = case src
      when String
        options[:body] = src
        digest   = OpenSSL::Digest::Digest.new('sha1')
        basename = OpenSSL::HMAC.digest(digest, @name, src)
        options.delete(:dest) || basename
      when File
        options[:body] = File.read(src.path)
        options.delete(:dest) || File.basename(src.path)
      else
        raise ArgumentError, "src must be either be a String or File"
      end
      path.gsub!(/\//, options.delete(:delimiter) || "/")

      options[:'content-type'] ||= MimeType.of path
      GoogleStorage::Object.new(self, path) { put options }
    rescue PreconditionFailedException
    end
    
    def [] path, options = { }
      GoogleStorage::Object.new(self, path) { open options }
    rescue 
      nil
    end
    
    # copy an object from another bucket into this bucket
    def copy src, options = { }
      path = options.delete(:dest) || File.basename(src)
      options[:'x-goog-copy-source'] = src
      GoogleStorage::Object.new(self, path) { put options }
    rescue PreconditionFailedException
    end
  end
end
