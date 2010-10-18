module GoogleStorage
  class Object < RequestMethods
    attr_reader :path
    attr_reader :fullpath
    attr_reader :content
    attr :acl
    
    def initialize bucket, path, &block
      @path          = path
      @fullpath      = File.join(bucket.name, path)
      @bucket        = bucket
      @authorization = bucket.authorization
      instance_eval &block if block_given?
    end
   
    def get options = { }
      config = { :path => @fullpath } * options
      exec(:get, config) { |headers, content| load_metadata headers, content }
      self
    end
    
    def put options = { }
      config = { :path => @fullpath } * options
      exec(:put, config) { |headers, content| load_metadata headers, content }
      self
    end
    
    def save path, overwrite = false
      path = File.join(path, File.basename(@path)) \
        if File.directory? path
          
      raise IOError, "File `#{path}' already exist." \
        if File.file?(path) && !overwrite

      File.write(path, @content)
    end

    def destroy
      destroy! 
      true
    rescue NotFoundException
      false
    end

    def destroy!
      exec :delete, :path => @fullpath
      @content = nil
      @acl     = nil
    end

    def acl
      unless @acl
        doc = exec :get, :path => @fullpath, :acl => true
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
        #puts "- #{k}: #{v}"
        normalize = lambda do |k, v| 
          case k
          when /^(expires|last_modified|date)$/: DateTime.parse(v)
          when /^content_length$/: v.to_i
          else v
          end
        end
        this.class_eval{ attr_reader k.to_sym }
        instance_variable_set :"@#{k}", normalize[k, v]
      end
    end
  end
end