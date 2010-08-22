module GoogleStorage
  # uri to gs services api
  HOST = "commondatastorage.googleapis.com"

  # TODO: need better error management
  class RequestMethodException < Exception; end
  class ServiceListBucketsException < RequestMethodException; end
  class BucketCreateException < RequestMethodException; end
  class BucketDeleteException < RequestMethodException; end
end