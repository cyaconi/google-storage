module GoogleStorage
  module Configuration
    attr :ssl
    attr :provider
    
    def initialize(config_path_or_hash)
      config = case config_path_or_hash
      when String: YAML.load(File.read config)
      when Hash: config
      else raise ArgumentError, "config must either be a Hash, or String"
      end
      config.recursively!{ |h| h.symbolize_keys! }
      @provider = config[:provider]
      @ssl      = config[:ssl]
      config[:authorization].each do |k, v|
        next if [:id, :email, :'group-email', :'apps-domain'].include? k
        (@authkeys ||= {})[k] = v
      end
    end
    
    def authorization label = nil
      keypair = label.empty? ? @authkeys.first : @authkeys[label.to_sym]
      Authorization.new keypair[:'access-key'], keypair[:'secret-key']
    end
  end
end