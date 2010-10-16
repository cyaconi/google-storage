module GoogleStorage
  HOST = "commondatastorage.googleapis.com"

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