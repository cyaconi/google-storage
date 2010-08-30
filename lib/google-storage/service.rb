module GoogleStorage
  class Service < RequestMethods
    def initialize(authorization, &block)
      @authorization = authorization
      instance_eval &block if block_given?
    end

    # lists all of the buckets that are owned by the requester.
    def buckets
      res, doc = exec(:get)
      raise_error doc unless res.instance_of? Net::HTTPOK
      normalize = lambda{ |k, v| k == :creation_date ? DateTime.parse(v) : v }
      doc.xpath("//xmlns:Bucket").map{ |node| node.to_h(&normalize) }
    end
   
    # get the named bucket. returns an instance of Bucket if the bucket exists.
    # if autocreate is true, then the bucket is first created before returning
    # an instance of Bucket.
    def get(bucket, autocreate = false)
      begin
        bucket = Bucket.new(bucket, @authorization, autocreate)
        bucket if bucket.exists?
      rescue InvalidBucketNameException => e
        raise e if autocreate
      end
    end
  end
end