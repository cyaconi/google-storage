module GoogleStorage
  class Authorization
    # creates an Authorization string generator
    # using the declared keys in config.
    def initialize(label, config = {})
      @config = if config.empty?
        YAML.load(File.read "google-storage.yml")
      elsif config.instance_of? String
        YAML.load(File.read config)
      else
        config
      end
      @config.recursively!{ |h| h.symbolize_keys! }
      @keys = @config[label.to_sym]
    end
    
    # generates an authorization string for the 
    # request object based on type.
    def generate(req, authsig)
      "#{authsig} #{@keys[:access_key]}:#{signature message(req)}"
    end
    
    private
    # generate a base64 encoded sha1 digest of the message
    def signature(message)
      Base64.encode64(HMAC::SHA1.digest(@keys[:secret_key], message)).gsub("\n", "").toutf8
    end

    # construct the message to sign string based on 
    # the contents of the request object
    def message(req)
      # canonical headers
      verb         = req.class.name.split("::").last.upcase
      content_md5  = ""
      content_type = req["content-type"]
      date         = req["date"]
  
      # canonical extension headers
      ext = req.to_hash.keys.delete_if{ |k| k !~ /^x-goog-/ }.sort.map{ |k| "#{k}:#{req[k]}" }.join("\n")
      ext << "\n" unless ext.empty?
  
      # canonical resource
      path = req.path
      path.sub!(/\?.+/, '') unless path =~ /\?acl/
  
      # message to sign
      "#{verb}\n#{content_md5}\n#{content_type}\n#{date}\n#{ext}#{path}".toutf8
    end
  end
end