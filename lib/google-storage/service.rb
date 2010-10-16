module GoogleStorage
  class Service < RequestMethods
    def initialize(authorization)
      @authorization = authorization
    end
    
    # returns a Bucket object
    # raise an exception if then named bucket does not exist
    def [] name
      Bucket.open(name.to_s, @authorization)
    end
    
    # returns a list of buckets owned as described by 
    # the Authorization used at instantiation
    def buckets
      res, doc = exec(:get)
      raise_error doc unless res #== 200
      normalize = lambda{ |k, v| k == :creation_date ? DateTime.parse(v) : v }
      doc.xpath("//xmlns:Bucket").map{ |node| node.to_h(&normalize) }
    end
  end
end