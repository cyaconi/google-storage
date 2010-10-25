module GoogleStorage
  class Service < RequestMethods
    # configuration is an instance of GoogleStorage::Configuration;
    # label refers to the label of the keypair to us when computing 
    # the authorization string
    #
    # sample usage:
    # 
    #   config = Configuration.new("/path/to/google-storage.yml")
    #   Service.new(config, :development)
    #
    def initialize configuration, label=nil
      @configuration = configuration
      @authorization = configuration.authorization(label)
    end
    
    # returns a Bucket object
    # raise an exception if then named bucket does not exist
    def [] name
      Bucket.open(name.to_s, @authorization)
    end
    
    # returns a list of buckets owned as described by 
    # the Authorization used at instantiation
    def buckets
      doc       = exec :get
      normalize = lambda{ |k, v|  k == :creationdate ? DateTime.parse(v) : v }
      doc.xpath("//xmlns:Bucket").map{ |node| node.to_h(&normalize) }
    end
  end
end
