module GoogleStorage
  class RequestMethods
    USER_AGENT           = "Juris Galang, GoogleStorage Gem/1.0"
    DEFAULT_CONTENT_TYPE = "application/x-www-form-urlencoded"
    
    def timestamp
      Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
    end
  
    def authorize(req, authsig = "GOOG1")
      req["authorization"] = @authorization.generate(req, authsig)
    end
    
    def raise_error(error)
      code    = error.xpath("/Error/Code").text
      message = error.xpath("/Error/Message").text
      raise GoogleStorage::RequestMethodException(code), "#{message}" 
    end
    
    def exec(verb, options = { })
      uri    = URI.parse("http://#{HOST}/")
      body   = options.delete(:body)
      stream = options.delete(:'body-stream')
      params = options.delete(:params)
      params = params.map{ |k, v| "#{k}=#{v}" }.join("&") unless params.blank? 
      path   = options.delete(:path) || uri.path
      path << "?#{params}" unless params.blank? || path =~ /\?acl$/
      
      req = Kernel.constant("Net::HTTP::#{verb.to_s.capitalize}").new(path)
      req["content-length"] = body.nil? ? "0" : body.to_s.length
      req["content-type"]   = DEFAULT_CONTENT_TYPE
      req["user-agent"]     = USER_AGENT
      req["date"]           = timestamp
      req["host"]           = uri.host
      options.each{ |k, v| req[k.to_s] = v }
      authorize(req)
      
      req.body_stream = stream unless stream.nil?
      res = Net::HTTP.new(uri.host, uri.port).start{ |http| http.request(req, body) } 
      doc = Nokogiri::XML(res.body) 
      
      [ res, doc ]
    end
  end
end