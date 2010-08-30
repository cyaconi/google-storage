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
      path   = options.delete(:path) || uri.path
      params = options.delete(:params)
      unless params.nil? or params.empty?
        params.stringify_keys!
        path << "?#{params.keys.sort.map{ |k| "#{k}=#{params[k]}"}.join("&")}"
      end
      puts ">>>>>> #{path}"
      req = Kernel.constant("Net::HTTP::#{verb.to_s.capitalize}").new(path)
      req["content-length"] = body.nil? ? "0" : body.to_s.length
      req["content-type"]   = DEFAULT_CONTENT_TYPE
      req["user-agent"]     = USER_AGENT
      req["date"]           = timestamp
      req["host"]           = uri.host
      options.each{ |k, v| req[k.to_s] = v }
      #req.each{ |k, v| puts "#{k}:\t#{v}" }
      authorize(req)
      
      res = Net::HTTP.new(uri.host).start{ |http| http.request(req, body) }
      doc = Nokogiri::XML(res.body) 
      
      [ res, doc ]
    end
  end
end