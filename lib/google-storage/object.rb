module GoogleStorage
  class Object < RequestMethods
    attr_reader :path
    attr_reader :canonicalpath
    attr_reader :content
    attr :acl

    def initialize bucket, path, &block
      @path          = path
      @canonicalpath = [ bucket.name, path ].join("/").gsub(/\/{2,}/, "/")
      @bucket        = bucket
      @credentials   = bucket.credentials
      instance_eval &block if block_given?
    end
    
    def file?
      not folder?
    end
    
    def folder?
      @canonicalpath.match(/_\$folder\$$/) != nil
    end
    
    alias :directory? :folder?
    
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
      config = { :path => @canonicalpath } * options
      config[:range] = "bytes=0-0"
      exec(:get, config) { |headers, content| load_metadata headers, nil }
      self
    end
    
    def get options = { }
      config = { :path => @canonicalpath } * options
      exec(:get, config) { |headers, content| load_metadata headers, content }
      self
    end
    
    def put options = { }
      config = { :path => @canonicalpath } * options
      exec(:put, config) { |headers, content| load_metadata headers, content }
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
      exec :delete, :path => @canonicalpath
      @content = nil
      @acl     = nil
    end

    def acl
      unless @acl
        doc  = exec :get, :path => @canonicalpath, :acl => true
        @acl = Acl.new(doc)
      end
      @acl
    end
    
    def acl= acl
      exec :put, :path => @canonicalpath, :acl => true, :body => acl.to_s
      @acl = nil
    end
    
    private
    def load_metadata h, content
      @content = content
      #headers.rekey! { |k| (k =~ /^(ID|ETag)$/ ? \
      #  k.downcase : k).methodize.gsub(/-/, '_') }
      # headers = h.rekey{ |k| k.downcase.gsub(/-/, '_') }
      headers = h.map {|k,v| [k.downcase.gsub(/-/,'_'),v]}
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
