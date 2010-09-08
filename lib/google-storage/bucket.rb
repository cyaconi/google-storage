module GoogleStorage
  class Bucket < RequestMethods
    attr_reader :name
    attr_reader :authorization
    
    def initialize(name, authorization, autocreate = false, &block)
      @name          = name
      @authorization = authorization
      
      # do a get service request - see if bucket exists
      # if bucket DOES NOT EXIST then create it if autocreate is true
      # if autocreate is false then do nothing???
      create if not exists? and autocreate
      instance_eval &block if block_given?
    end

    # Check if a bucket exists
    def exists?
      not acl.nil?
    end
    
    # Create a bucket, raise an error if unable to do so
    def create(acl = nil)
      options = { :path => "/#{@name}/" }
      options[:'x-goog-acl'] = acl.to_s unless acl.nil?
      res, doc = exec(:put, options)
      raise_error doc unless res.instance_of? Net::HTTPOK
    end

    # Get the ACLs of the bucket
    def acl
      res, doc = exec(:get, :path => "/#{@name}/?acl")
      if res.instance_of? Net::HTTPOK
        Acl.new(doc)
      else
        raise_error doc unless res.instance_of? Net::HTTPNotFound
      end
    end

    # Set the ACL of the bucket
    def acl=(acl)
      options  = { :path => "/#{@name}/?acl", :body => acl.to_s }
      res, doc = exec(:put, options)
      raise_error doc unless res.instance_of? Net::HTTPOK
    end
    
    # destroy/delete bucket
    def destroy
      res, doc = exec(:delete, :path => "/#{@name}/")
      raise_error doc unless res.instance_of? Net::HTTPNoContent
    end
      
    # Get the list of objects in a bucket
    #
    # delimiter	A character or multiple characters that can be used to simplify 
    #           a list of objects that use a directory-like naming scheme. 
    #           Can be used in conjunction with a prefix.	
    # marker	  The object name from which you want to start listing objects.
    # max-keys	The maximum number of objects to return in a list object request.	
    # prefix	  A string that can be used to limit the number of objects that are 
    #           returned in a GET Bucket request. Can be used in conjunction with a 
    #           delimiter.
    # 
    # NOTE: Google Storage does not return lists longer than 1,000 objects.
    # TODO: delimiter, marker, prefix, etc does not seem to have any effect on the
    #       list of objects returned. it's possible that the request is not being
    #       sent correctly (ie: the querystring is not recognized)
    def contents(options = { })
      res, doc = exec(:get, :path => "/#{@name}/", :params => options)
      raise_error doc unless res.instance_of? Net::HTTPOK
      normalize = lambda do |k, v| 
        case k
        when 'last_modified' then DateTime.parse(v)
        when 'size'          then v.to_i
        when 'e_tag'         then v.sub(/"/, '')
        when 'owner'         then Acl::Owner.new(v)
        else v
        end
      end
      # doc.xpath("//xmlns:CommonPrefixes/Prefix").map{ |node| node.text }
      # @truncated = doc.xpath("//xmlns:IsTruncated").text =~ /^true$/i
      doc.xpath("//xmlns:Contents").map{ |node| node.to_h(&normalize) }
    end
    
    def put(object, key, options = { })
      options[:path] = "/#{@name}/#{key}"
      case object
      when File
        options[:'body-stream']    = object
        options[:'content-length'] = File.size(object)
        options[:'content-type']   = MimeType.of(object.path)
      when String
        options[:body]           = object
        options[:'content-type'] = MimeType.of(key)
      else
        # raise error?
      end
      res, doc = exec(:put, options)
      raise_error doc unless res.instance_of? Net::HTTPOK
    end
  end
end
