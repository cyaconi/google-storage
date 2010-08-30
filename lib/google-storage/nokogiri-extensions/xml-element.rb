class Nokogiri::XML::Element
  def to_h
    self.children.map{ |child| 
      k = (child.name =~ /^ID$/ ? child.name.downcase : child.name).methodize
      v = child.children.first.instance_of?(Nokogiri::XML::Text) ? child.children.first.text.strip : child.to_h
      v = yield k, v if block_given?
      [ k, v ]
    }.to_h.symbolize_keys
  end
end
