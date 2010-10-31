module GoogleStorage
  DEFAULT_HOST     = "commondatastorage.googleapis.com"
  DEFAULT_PROVIDER = "GOOG1"
  DEFAULT_PROTOCOL = "https"

  class RequestMethodException < Exception; end
  
  def self.RequestMethodException(name)
    const = "#{name}Exception".to_sym
    if GoogleStorage.const_defined? const
      GoogleStorage.const_get const
    else
      klass = Class.new(RequestMethodException)
      GoogleStorage.const_set const, klass
    end
  end
end