module GoogleStorage
  class Configuration
    attr_reader :protocol
    attr_reader :provider
    attr_reader :host
    
    def initialize(config_path_or_hash)
      config = case config_path_or_hash
      when String: YAML.load(File.read config_path_or_hash)
      when Hash: config_path_or_hash
      else raise ArgumentError, "config must either be a Hash or String"
      end
      config.recursively!{ |h| h.symbolize_keys! }
      settings  = config[:settings]
      @provider = settings[:provider] || DEFAULT_PROVIDER
      @protocol = settings[:ssl] == false ? 'http' : DEFAULT_PROTOCOL
      @host     = settings[:host] || DEFAULT_HOST
      config[:credentials].each do |k, v|
        next if [:id, :email, :'group-email', :'apps-domain'].include? k
        (@authkeys ||= {})[k] = v
      end
    end
    
    def credentials label = nil
      keypair = label.nil? ? @authkeys.first : @authkeys[label.to_sym]
      Credentials.new keypair
    end
  end
  
  # apply configuration object to gem runtime
  # TODO: not really sure about this method... smells bad somehow
  def self.settings configuration
    @@settings = configuration
  end
  
  def method_missing name, *args
    if args.empty? && [ :protocol, :host, :provider ].include?(name)
      class_variable_defined?(:@@settings) ? @@settings.send(name) : const_get(:"DEFAULT_#{name.to_s.upcase}")
    else 
      super name, args
    end
  end
end