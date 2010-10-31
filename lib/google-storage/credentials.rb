module GoogleStorage
  class Credentials
    def self.parse(credentials)
      case credentials
      when Credentials
        credentials
      when Hash
        Credentials.new credentials.symbolize_keys
      else raise ArgumentError, \
        "credentials must be one of Credentials, or Hash"
      end
    end
    
    # creates an Credentials string generator using the key-pair
    def initialize(keypair)
      @keypair = keypair
    end
    
    # generates an authorization string
    def authorization(verb, path, headers, authsig)
      "#{authsig} #{@keypair[:accesskey]}:" \
      "#{signature message(verb, path, headers)}"
    end
    
    private
    # generate a base64 encoded sha1 digest of the message
    def signature(message)
      digest = OpenSSL::Digest::Digest.new('sha1')
      Base64.encode64(OpenSSL::HMAC.digest(digest, \
        @keypair[:secretkey], message)).gsub("\n", "").toutf8
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