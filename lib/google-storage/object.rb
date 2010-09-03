module GoogleStorage
  class Object < RequestMethods
    attr_reader :key
    
    # bucket is the name of the bucket where the object belongs
    # authorization the authorization string generator to use
    # key is the key or path that uniquely identifies the object in the bucket
    def initialize(bucket, key, authorization)
      @bucket        = bucket
      @key           = key
      @authorization = authorization
    end
  end
end