require 'rubygems'
require 'typhoeus'
require 'json'

hydra   = Typhoeus::Hydra.new
request = Typhoeus::Request.new("http://www.pauldix.net",
                                :body          => "this is a request body",
                                :method        => :post,
                                :headers       => {:Accept => "text/html"},
                                :timeout       => 100, # milliseconds
                                :cache_timeout => 60, # seconds
                                :params        => {:field1 => "a field"})
# we can see from this that the first argument is the url. the second is a set of options.
# the options are all optional. The default for :method is :get. Timeout is measured in milliseconds.
# cache_timeout is measured in seconds.


# the response object will be set after the request is run
#response = request.response
#response.code    # http status code
#response.time    # time in seconds the request took
#response.headers # the http headers
#response.headers_hash # http headers put into a hash
#response.body    # the response body

request.on_complete do |response|
  puts response
end
hydra.queue request
hydra.run