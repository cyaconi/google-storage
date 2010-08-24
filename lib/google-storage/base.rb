module GoogleStorage
  # uri to gs services api
  HOST = "commondatastorage.googleapis.com"

  def self.RequestMethodException(name)
    klass = Class.new(Exception)
    GoogleStorage.const_set "#{name}Exception", klass
  end
  
  ## TODO: need better error management
  #class RequestMethodException < Exception
  #  def self.synthesize(name)
  #    klass = Class.new self
  #    Object.const_set name, klass
  #  end
  #end
end