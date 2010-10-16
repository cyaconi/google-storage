module GoogleStorage
  class Object < RequestMethods
    attr_reader :path
    attr_reader :content
    attr :acl
    
    def initialize(bucket, path)
      @path          = path
      @fullpath      = "#{bucket.name}/#{path}"
      @bucket        = bucket
      @authorization = bucket.authorization
    end
    
    def delete
      res, doc = exec(:delete, :path => @fullpath)
      raise_error doc unless res #== 204
      @content = nil
      @acl     = nil
    end
    
    def download(options = {})
      config  = { :path => @fullpath } * options
      res, doc, headers, @content = exec(:get, config)
      raise_error doc unless res #== 200
      headers.rekey! { |k| k.downcase.gsub(/-/, '_') }
    
      this = class << self; self; end
      headers.each do |k, v|
        next if k =~ / / 
        puts "- #{k}: #{v}"
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
      yield @path, @content if block_given?
      self
    end
    
    def upload(content, options)
    end
    
    def acl
      unless @acl
        res, doc = exec(:get, :path => @fullpath, :acl => true)
        raise_error doc unless res #== 200
        @acl = Acl.new(doc)
      end
      @acl
    end
    
    def acl= acl
      options  = { :path => @fullpath, :acl => true, :body => acl.to_s }
      res, doc = exec(:put, options)
      raise_error doc unless res #== 200
      @acl = acl
    end
  end
end