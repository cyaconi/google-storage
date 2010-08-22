module GoogleStorage
  class Acl
    # used when specifiying x-goog-acl
    PRIVATE                       = 'private'
    PUBLIC_READ                   = 'public-read'
    PUBLIC_READ_WRITE             = 'public-read-write'
    AUTHENTICATED_READ            = 'authenticated-read'
    BUCKET_OWNER_READ             = 'bucket-owner-read'
    BUCKET_OWNER_FULL_CONTROL     = 'bucket-owner-full-control'

    # used when declaring permission in acl document
    PERMISSION_READ               = 'READ'
    PERMISSION_WRITE              = 'WRITE'
    PERMISSION_FULL_CONTROL       = 'FULL_CONTROL'

    # used when declaring scope type in acl document
    SCOPE_USER_BY_ID              = 'UserById'
    SCOPE_USER_BY_EMAIL           = 'UserByEmail'
    SCOPE_GROUP_BY_ID             = 'GroupById'
    SCOPE_GROUP_BY_EMAIL          = 'GroupByEmail'
    SCOPE_GROUP_BY_DOMAIN         = 'GroupByDomain'
    SCOPE_ALL_USERS               = 'AllUsers'
    SCOPE_ALL_AUTHENTICATED_USERS = 'AllAuthenticatedUsers'

    # TODO: need beter names
    REGULAR_SCOPE_TYPES           = [ :group, :user ]
    SPECIAL_SCOPE_TYPES           = [ :all_users, :all_authenticated_users ]
    ALLOWED_SCOPE_TYPES           = REGULAR_SCOPE_TYPES + SPECIAL_SCOPE_TYPES
    
    def self.valid_permission? value
      const_defined?(:"PERMISSION_#{value}")
    end  

    def self.special_scope? value
      SPECIAL_SCOPE_TYPES.include?(value.to_sym) 
    end

    def self.valid_scope? value
      ALLOWED_SCOPE_TYPES.include?(value.to_sym) 
    end
    
    def self.identity_attr_name(scope)
      key = scope.sub(/^[A-Za-z]+By/, '').methodize + (scope =~ /Email/ ? '_address' : '')
      key = "canonical_id" if key =~ /^id$/
      key.to_sym
    end
    
    def self.identity_type(identity)
      if email?(identity)
        "email"
      elsif domain?(identity)
        "domain"
      elsif canonical_id?(identity)
        "id"
      else
        raise ArgumentError, "identity must be an email address, domain name, or a Google ID"
      end
    end

    def self.email?(identity)
      (identity =~ /@/) && (identity =~ /\./)
    end

    def self.domain?(identity)
      (identity =~ /\./) && !email?(identity)
    end

    def self.canonical_id?(identity)
      (identity.length == 64) && !domain?(identity) && !email?(identity)
    end
  end
  
  class Acl
    include Enumerable
    attr_reader :owner

    def initialize(acl=nil)
      doc = if acl.instance_of? String
        Nokogiri::XML(acl)
      elsif acl.respond_to? :read
        Nokogiri::XML(acl.read)
      elsif acl.respond_to? :xpath
        acl
      else
        raise ArgumentError, "The parameter `acl` must either be a String, an IO, or an XML document object"
      end

      raise doc.errors.first unless doc.errors.empty?
        
      extract = lambda do |child| 
        k = child.name =~ /^ID$/ ? child.name.downcase : child.name
        v = child.text.strip
        [ k.methodize.to_sym, v ] 
      end
      
      identity = doc.xpath("//Owner/*").map(&extract).to_h
      @owner   = Owner.new(identity)
      @entries = doc.xpath("//Entries/*").map do |node|
        scope      = node.xpath("Scope/@type").to_s
        permission = node.xpath("Permission").text
        identity   = node.xpath("Scope/*").map(&extract).to_h
        args       = [ permission ]
        args << identity unless Acl.special_scope? scope.methodize
        Entry.send(scope, *args)
      end
    end

    def length
      @entries.length
    end
  
    def each(&blk)
      @entries.each(&blk)
    end
    
    def to_xml
      doc = Nokogiri::XML::Builder.new(:encoding => 'utf-8'){ |xml| xml.AccessControlList{ xml.Entries } }
      doc = Nokogiri::XML(doc.to_xml)
      doc.at("Entries").before(@owner.to_xml.at("Owner"))
      @entries.each do |entry|
        doc.at("Entries").add_child(entry.to_xml.at("Entry"))
      end
      doc
    end
    
    def to_s
      to_xml.to_s
    end

    def remove(entry)
      other = Entry.parse(entry)
      @entries.delete_if{ |entry| entry.is? other }
    end
    
    def add(entry)
      other = Entry.parse(entry)
      remove(other)
      @entries << other
    end
  end
end
