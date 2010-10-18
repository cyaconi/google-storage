module GoogleStorage
  class Object < RequestMethods
    attr_reader :path
    attr_reader :fullpath
    attr_reader :content
    
    def initialize bucket, path
      @path          = path
      @fullpath      = File.join(bucket.name, path)
      @bucket        = bucket
      @authorization = bucket.authorization
    end
    
    def get options = { }
      config = { :path => @fullpath } * options
      exec(:get, config) do |headers, content|
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
          this.class_eval{ attr_reader k.to_sym }
          instance_variable_set :"@#{k}", normalize[k, v]
        end
      end
      yield @path, @content if block_given?
      self
    end
  end
end