class Foo
  def bar
    puts "foobar"
  end
  
  def open(&block)
    instance_eval &block if block_given?
  end
  
  def self.open(&block)
    Foo.new.open(&block)
  end
end

foo = Foo.new
foo.open
foo.open{ bar }
Foo.open{ bar }
Foo.open