module GoogleStorage
  class RequestMethods
    USER_AGENT           = "Juris Galang, GoogleStorage Gem/1.0"
    DEFAULT_CONTENT_TYPE = "application/x-www-form-urlencoded"
    
    def timestamp
      Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
    end
    
    def raise_error(error)
      code    = error.xpath("/Error/Code").text
      message = error.xpath("/Error/Message").text
      raise GoogleStorage::RequestMethodException(code), "#{message}" 
    end

    def exec(verb, options = { })
      verb = verb.to_s.upcase
      body = options.delete(:body)
      path = options.delete(:path)
      url  = URI.parse("#{protocol}://#{host}/#{path}")
      
      puts ">>>>>#{url}<<<<<<<<<"

      headers = { }
      headers['Content-Length'] = body.nil? ? "0" : body.to_s.length
      headers['Content-Type']   = options.delete(:'content-type') || DEFAULT_CONTENT_TYPE
      headers['User-Agent']     = USER_AGENT
      headers['Date']           = timestamp
      headers['Host']           = url.host
      options.each{ |k, v| headers[k.to_s] = v }

      params = options.delete(:params)
      path   = url.path 
      path << "?acl" if options.delete(:acl)
      headers['Authorization'] = @credentials.authorization(verb, path, headers, provider)
      
      config = { 
        :method  => verb,
        :headers => headers.stringify_keys
      }
      config[:params] = params unless params.nil? or params.empty?
      config[:body]   = body unless body.nil? or body.empty?
  
      @hydra ||= Typhoeus::Hydra.new
      req = Typhoeus::Request.new(url.to_s, config)
      req.on_complete do |res|
        doc = Nokogiri::XML(res.body)
        raise_error doc unless res.success?
        if block_given?
          yield res.headers_hash, res.body 
        else
          doc
        end
      end
      @hydra.queue req
      @hydra.run                                
      
      req.handled_response
    end
    
    private
    # TODO: un-uglify this implementation
    def protocol
      @@configuration ? @@configuration.protocol : 'https'
    end
    
    # TODO: un-uglify this implementation
    def host
      @@configuration ? @@configuration.host : HOST
    end

    # TODO: un-uglify this implementation
    def provider
      @@configuration ? @@configuration.provider : 'GOOG1'
    end
  end
end