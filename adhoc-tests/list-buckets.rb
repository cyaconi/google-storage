require 'rubygems'

require 'cgi'
require 'net/http'
require 'uri'
require 'base64'
require 'kconv'
require 'yaml'

require 'nokogiri'
require 'openssl'

require 'facets/hash/recursively'
require 'facets/hash/symbolize_keys'
require 'facets/hash/stringify_keys'

module GoogleStorage
  class Authorization
    # creates an Authorization string generator
    # using the declared keys in config.
    def initialize(label, config = {})
      @config = if config.empty?
        YAML.load(File.read "fixtures/google-storage.yml")
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
      digest = OpenSSL::Digest::Digest.new('sha1')
      Base64.encode64(OpenSSL::HMAC.digest(digest, @keys[:secret_key], message)).gsub("\n", "").toutf8
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
      puts "#{verb}\n#{content_md5}\n#{content_type}\n#{date}\n#{ext}#{path}".toutf8
      "#{verb}\n#{content_md5}\n#{content_type}\n#{date}\n#{ext}#{path}".toutf8
    end
  end
end

HOST         = "commondatastorage.googleapis.com"
REQUEST_DATE = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")

url = URI.parse("http://#{HOST}/")
req = Net::HTTP::Get.new('/travel-map/')
puts req.path
req["user-agent"]     = "Ruby/1.8"
req["content-type"]   = "application/x-www-form-urlencoded"
req["content-length"] = 0
req["host"]           = url.host
req["date"]           = REQUEST_DATE
req["authorization"]  = GoogleStorage::Authorization.new("test").generate(req, 'GOOG1')

#res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }

#puts res.body

require 'typhoeus'
require 'json'
hydra   = Typhoeus::Hydra.new
request = Typhoeus::Request.new("http://#{HOST}/travel-map/",
                                :headers => { :'user-agent'     => "Ruby/1.8", 
                                              :'content-type'   => "application/x-www-form-urlencoded",
                                              :'content-length' => "0",
                                              :host             => HOST,
                                              :date             => REQUEST_DATE,
                                              :authorization    => req["authorization"] },
                                :params => { :prefix => "europe/france" } )
#request = Typhoeus::Request.new("http://#{HOST}/travel-map/",
#                                :method  => "PUT",
#                                :headers => { :'user-agent'     => "Ruby/1.8", 
#                                              :'content-type'   => "application/x-www-form-urlencoded",
#                                              :'content-length' => "0",
#                                              :host             => HOST,
#                                              :date             => REQUEST_DATE,
#                                              :authorization    => req["authorization"] })
request.on_complete do |response|
  puts response.code
  puts response.time
  puts response.headers
  puts response.body
end
hydra.queue request
hydra.run                                
#                                
#puts request.response
##url = URI.parse("http://#{HOST}/")
#req = Net::HTTP::Put.new('/jurisgalang/')
#puts req.path
#req["user-agent"]     = "Ruby/1.8"
#req["content-type"]   = "application/x-www-form-urlencoded"
#req["content-length"] = 0
#req["host"]           = url.host
#req["date"]           = REQUEST_DATE
#req["x-goog-acl"]     = "public-read-write"
#req["authorization"]  = GoogleStorage::Authorization.new("development").generate(req, 'GOOG1')
#
#res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
#puts res.body
