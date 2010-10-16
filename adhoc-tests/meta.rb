class Foo
  attr_reader :content
  
  def initialize
    @content = 'foobar'
  end
  
  def bar
    this = class << self; self; end
    this.class_eval{ attr_reader :length }
    instance_variable_set :'@length', @content.length
  end
end

foo = Foo.new
puts foo.content
foo.bar
puts foo.length
