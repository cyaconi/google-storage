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
      url  = URI.parse("http://#{HOST}/#{path}")
      
      headers = { }
      headers['Content-Length'] = body.nil? ? "0" : body.to_s.length
      headers['Content-Type']   = DEFAULT_CONTENT_TYPE
      headers['User-Agent']     = USER_AGENT
      headers['Date']           = timestamp
      headers['Host']           = url.host
      options.each{ |k, v| headers[k.to_s] = v }
      
      params = options.delete(:params)
      path   = url.path 
      path << "?acl" if options.delete(:acl)
      headers[:"authorization"] = @authorization.generate(verb, path, headers, "GOOG1")
      
      config = { 
        :method  => verb,
        :body    => body,
        :headers => headers.stringify_keys,
        :params  => params 
      }
      
      @hydra ||= Typhoeus::Hydra.new
      req = Typhoeus::Request.new(url.to_s, config)
      #req.on_complete{ |res| [ res.code, Nokogiri::XML(res.body), \
      #  res.headers_hash, res.body ] }
      req.on_complete{ |res| [ res.success?, Nokogiri::XML(res.body), \
        res.headers_hash, res.body ] }
      @hydra.queue req
      @hydra.run                                
      
      req.handled_response
    end
  end
end