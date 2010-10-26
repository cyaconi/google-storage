module GoogleStorage
  class Service < RequestMethods
    def initialize credentials
      @credentials = credentials
    end
    
    # returns a Bucket object
    # raise an exception if then named bucket does not exist
    def [] name
      Bucket.open(name.to_s, @credentials)
    end
    
    # returns a list of buckets owned as described by 
    # the Credentials used at instantiation
    def buckets
      doc       = exec :get
      normalize = lambda{ |k, v|  k == :creationdate ? DateTime.parse(v) : v }
      doc.xpath("//xmlns:Bucket").map{ |node| node.to_h(&normalize) }
    end
  end
end
