module GoogleStorage
  class Acl
    class Owner
      attr_reader :canonical_id
      attr_reader :name

      has_named_parameters :initialize, :required => :id, :optional => [ :name, :display_name ]
      def initialize(identity)
        identity = identity.to_h if identity.respond_to? :xpath
        raise ArgumentError, "Canonical ID must be specified." unless Acl.canonical_id? "#{identity[:id]}"
        @canonical_id = "#{identity[:id]}"
        @name         = "#{identity[:name]}"
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
      
      def as_acl_entry
        Entry.UserById(Acl::PERMISSION_FULL_CONTROL, :id => @canonical_id, :name => @name)
      end
    end
  end
end
