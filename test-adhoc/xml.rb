require 'nokogiri'

a = Nokogiri::XML::Builder.new do |xml|
  xml.root {
    xml.products {
      xml.widget {
        xml.id_ "10"
        xml.name "Awesome widget"
      }
    }
  }
end

@objects = [Object.new, Object.new, Object.new]
b = Nokogiri::XML::Builder.new do |xml|
  xml.root {
    xml.objects {
      @objects.each do |o|
        xml.object {
          xml.type_   o.type
          xml.class_  o.class.name
          xml.id_     o.id
        }
      end
    }
  }
end

aa = Nokogiri::XML(a.to_xml)
bb = Nokogiri::XML(b.to_xml)
##aa = aa.fragment(aa.xpath("//widget").to_xml)
bb.document.root.add_child(aa.fragment(aa.xpath("//widget")))
puts bb.to_xml
