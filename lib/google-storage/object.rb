module GoogleStorage
  class Object < RequestMethods
    attr_reader :path      # the object's path/key relative to the bucket
    attr_reader :fullpath  # the object's path/key prefixed with its bucket name
    attr_reader :content   # the body/content of the object
    attr :acl

    # NOTE: the method for computing an object's fullpath does not feel right
    # it should probably be named `canonicalpath`, but not sure if the 
    # protocol (which seems to be gs://) should also be included in it - JG
    def initialize bucket, path, &block
      @path          = path
      @fullpath      = [bucket.name, path].join('/').gsub(/\/{2,}/, '/')
      @bucket        = bucket
      @authorization = bucket.authorization
      instance_eval &block if block_given?
    end
    
    # retrieves the object's metadata 
    # raises NoSuchKeyException if the object does not exist
    #
    # HACK: it should actually use:
    #
    #   exec(:head, config) { |headers, content| 
    #     load_metadata headers, content 
    #   }
    # 
    # but HEAD request is slow somehow. need to investigate how typhoues
    # does a HEAD request.
    def open options = { }
      config = { :path => @fullpath } * options
      config[:range] = "bytes=0-0"
      exec :get, config { |headers, content| load_metadata headers, content }
      self
    end
    
    def get options = { }
      config = { :path => @fullpath } * options
      exec :get, config { |headers, content| load_metadata headers, content }
      self
    end
    
    def put options = { }
      config = { :path => @fullpath } * options
      exec :put, config { |headers, content| load_metadata headers, content }
      self
    end
    
    def save path, overwrite = false
      path = File.join(path, File.basename(@path))   \
        if File.directory? path
      raise IOError, "File `#{path}' already exist." \
        if File.file?(path) && !overwrite
      File.write(path, @content)
    end

    def destroy
      destroy! 
      true
    rescue AccessDeniedException, # 404 Not Found
      NoSuchBucketException, 
      NoSuchKeyException
      false
    end

    def destroy!
      exec :delete, :path => @fullpath
      @content = nil
      @acl     = nil
    end

    def acl
      unless @acl
        doc  = exec :get, :path => @fullpath, :acl => true
        @acl = Acl.new(doc)
      end
      @acl
    end
    
    def acl= acl
      exec :put, :path => @fullpath, :acl => true, :body => acl.to_s
      @acl = acl
    end
    
    private
    def load_metadata headers, content
      @content = content
      headers.rekey! { |k| k.downcase.gsub(/-/, '_') }
      this = class << self; self; end
      headers.each do |k, v|
        next if k =~ / / 
        normalize = lambda do |k, v| 
          case k
          when /^(expires|last_modified|date)$/: DateTime.parse(v)
          when /^content_length$/: v.to_i
          else v
          end
        end
        varname = :"@#{k}"
        this.class_eval{ attr_reader k.to_sym } \
          unless instance_variable_defined? varname
        instance_variable_set varname, normalize[k, v]
      end
    end
  end
end
