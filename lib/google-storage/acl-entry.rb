module GoogleStorage
  class Acl
    class Entry
      private_class_method :new

      has_named_parameters :UserById, :required => :id
      def self.UserById(permission, identity)
        raise ArgumentError, "Canonical ID must be specified." unless Acl.canonical_id? "#{identity[:id]}"
        new(__method__, permission, identity[:id], identity[:name])
      end

      def self.UserByEmail(permission, identity)
        email = identity[:email] || identity[:email_address] || identity[:emailaddress]
        raise ArgumentError, "Email Address must be specified." unless Acl.email? "#{email}"
        new(__method__, permission, email, identity[:name])
      end

      has_named_parameters :GroupById, :required => :id
      def self.GroupById(permission, identity)
        raise ArgumentError, "Canonical ID must be specified." unless Acl.canonical_id? "#{identity[:id]}"
        new(__method__, permission, identity[:id], identity[:name])
      end

      def self.GroupByEmail(permission, identity)
        email = identity[:email] || identity[:email_address] || identity[:emailaddress]
        raise ArgumentError, "Email Address must be specified." unless Acl.email? "#{email}"
        new(__method__, permission, email, identity[:name])
      end

      has_named_parameters :GroupByDomain, :required => :domain
      def self.GroupByDomain(permission, identity)
        raise ArgumentError, "Domain Name must be specified." unless Acl.domain? "#{identity[:domain]}"
        new(__method__, permission, identity[:domain], identity[:name])
      end

      def self.AllUsers(permission)
        new(__method__, permission, nil, nil)
      end

      def self.AllAuthenticatedUsers(permission)
        new(__method__, permission, nil, nil)
      end
      
      # TODO: enforce key/value requirements when obj is Hash
      def self.parse(obj)
        case obj
        when Entry
          obj
        when Hash
          permission = obj[:permission]
          raise ArgumentError, "Invalid permission specified" unless Acl.valid_permission? permission
          
          scope = obj[:scope]
          raise ArgumentError, "Invalid scope, must be one of #{Acl::ALLOWED_SCOPE_TYPES.join(', ')}" \
            unless Acl.valid_scope? scope
          
          if Acl.special_scope? scope
            Entry.send("#{scope}".modulize, permission)
          else
            identity = obj[:identity]    # can't be nil, valid values: email, id, or domain string value
            name     = obj[:name]        # optional
            idtype   = Acl.identity_type(identity)
            Entry.send("#{scope}_by_#{idtype}".modulize, permission, { idtype.to_sym => identity, :name => name })
          end
        else
          raise ArgumentError, "Expecting an obj of type Hash or Acl::Entry"
        end
      end
      
      attr_reader :scope
      attr_reader :permission
      attr_reader :name
      attr_reader :identity
      
      def initialize(scope, permission, identity, name)
        @scope      = scope.to_s
        @permission = permission
        @identity   = identity
        @name       = name
        self.class.send(:define_method, identity_attr_name){ @identity }
      end

      def to_s
        { :scope => @scope, identity_attr_name => @identity, :name => @name, :permission => @permission }.inspect
      end

      def to_xml
        doc = Nokogiri::XML::Builder.new do |xml|
          xml.Entry{
            xml.Scope(:type => @scope){
              tag = identity_attr_name
              unless Acl.special_scope? tag
                tag = tag.to_s =~ /_id$/ ? :ID_ : "#{tag}".modulize.to_sym
                xml.send(tag, @identity)
                xml.Name(@name) unless @name.blank?
              end
            }
            xml.Permission(@permission)
          }
        end
        Nokogiri::XML(doc.to_xml)
      end
      
      def is?(obj)
        other = Entry.parse(obj)
        !((@scope =~ /^#{other.scope}$/) && 
          (@identity =~ /^#{other.identity}$/) && 
          (@permission =~ /^#{other.permission}$/)).nil?
      end
      
      private
      def identity_attr_name
        Acl.identity_attr_name(@scope)
      end
    end
  end
end
