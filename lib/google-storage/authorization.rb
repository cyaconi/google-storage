module GoogleStorage
  class Authorization
    # creates an Authorization string generator
    # using the declared keys in config.
    def initialize(label, config = { })
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
    
    # generates an authorization string
    def generate(verb, path, headers, authsig)
      "#{authsig} #{@keys[:'access-key']}:#{signature message(verb, path, headers)}"
    end
    
    private
    # generate a base64 encoded sha1 digest of the message
    def signature(message)
      digest = OpenSSL::Digest::Digest.new('sha1')
      Base64.encode64(OpenSSL::HMAC.digest(digest, @keys[:'secret-key'], message)).gsub("\n", "").toutf8
    end

    # construct the message to sign string
    def message(verb, path, headers)
      # canonical headers
      content_md5  = ""
      content_type = headers['Content-Type']
      date         = headers.has_key?(:'x-goog-date') ? '' : headers['Date']
  
      # canonical extension headers
      ext = headers.keys.delete_if{ |k| k.to_s !~ /^x-goog-/ }.sort.
        map{ |k| "#{k}:#{headers[k].strip.gsub(/[ \r\n\t]+/, " ")}" }.
        join("\n")
      ext << "\n" unless ext.empty?
  
      # canonical resource
      path.sub!(/\?.+/, '') unless path =~ /\?acl/

      # message to sign
      "#{verb.to_s.upcase}\n" \
      "#{content_md5}\n"      \
      "#{content_type}\n"     \
      "#{date}\n"             \
      "#{ext}#{path}".toutf8
    end
  end
end