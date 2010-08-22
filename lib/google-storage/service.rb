module GoogleStorage
  class Service < RequestMethods
    def initialize(authorization, &block)
      @authorization = authorization
      instance_eval &block if block_given?
    end

    # Lists all of the buckets that are owned by the requester.
    def buckets
      res, doc = exec(:get)
      
      unless res.instance_of? Net::HTTPOK
        code    = doc.xpath("/Error/Code").text
        message = doc.xpath("/Error/Message").text
        raise ServiceListBucketsException, "#{code}: #{message}" 
      end
      
      doc.xpath("//xmlns:Bucket").map do |node|
        { :name    => node.xpath("xmlns:Name").text, 
          :created => DateTime.parse(node.xpath("xmlns:CreationDate").text) }
      end
    end
   
    # Get the named bucket. 
    # Returns an instance of Bucket if the bucket exists.
    def get(bucket, autocreate = false)
      bucket = Bucket.new(bucket, @authorization, autocreate)
      bucket if bucket.exists?
    end
  end
end