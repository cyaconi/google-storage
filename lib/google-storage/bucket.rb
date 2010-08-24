module GoogleStorage
  class Bucket < RequestMethods
    attr_reader :name
    
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
      unless res.instance_of? Net::HTTPOK
        code    = doc.xpath("/Error/Code").text
        message = doc.xpath("/Error/Message").text
        raise GoogleStorage::RequestMethodException(code), "#{message}" 
      end
    end

    # Get the ACLs of the bucket
    # TODO: parse result
    def acl
      res, doc = exec(:get, :path => "/#{@name}/?acl")
      if res.instance_of? Net::HTTPOK
        Acl.new(doc)
      else
        unless res.instance_of? Net::HTTPNotFound
          code    = doc.xpath("/Error/Code").text
          message = doc.xpath("/Error/Message").text
          raise GoogleStorage::RequestMethodException(code), "#{message}" 
        end
      end
    end

    # Set the ACL of the bucket
    def acl=(acl)
      options  = { :path => "/#{@name}/?acl", :body => acl.to_s }
      res, doc = exec(:put, options)
      unless res.instance_of? Net::HTTPOK
        code    = doc.xpath("/Error/Code").text
        message = doc.xpath("/Error/Message").text
        raise GoogleStorage::RequestMethodException(code), "#{message}" 
      end
    end
    
    # delete bucket
    def delete
      res, doc = exec(:delete, :path => "/#{@name}/")
      unless res.instance_of? Net::HTTPNoContent
        code    = doc.xpath("/Error/Code").text
        message = doc.xpath("/Error/Message").text
        raise GoogleStorage::RequestMethodException(code), "#{message}" 
      end
    end
      
    # Get the list of objects in a bucket
    #
    # delimiter	A character or multiple characters that can be used to simplify 
    #           a list of objects that use a directory-like naming scheme. 
    #           Can be used in conjunction with a prefix.	
    # marker	  The object name from which you want to start listing objects.
    # max-keys	The maximum number of objects to return in a list object request.	
    # prefix	   A string that can be used to limit the number of objects that are 
    #            returned in a GET Bucket request. Can be used in conjunction with a 
    #           delimiter.
    def objects(options = {})
      #
    end
    
    # Save the changes in the bucket
    # TODO
    def save
    end
  end
end