module GoogleStorage
  class Acl
    class Owner
      attr_reader :canonical_id
      attr_reader :name

      def initialize(identity)
        @canonical_id = "#{identity[:id]}"
        raise ArgumentError, "A canonical id value must be specified using the `id` key" unless Acl.canonical_id? @canonical_id
        @name = "#{identity[:name]}"
      end
      
      def to_xml
        doc = Nokogiri::XML::Builder.new do |xml|
          xml.Owner{
            xml.ID_(@canonical_id)
            xml.Name(@name) unless @name.blank?
          }
        end
        Nokogiri::XML(doc.to_xml)
      end
    end
  end
end
