module GoogleStorage
  class Configuration
    attr :ssl
    attr :provider
    
    def initialize(config_path_or_hash)
      config = case config_path_or_hash
      when String: YAML.load(File.read config_path_or_hash)
      when Hash: config_path_or_hash
      else raise ArgumentError, "config must either be a Hash or String"
      end
      config.recursively!{ |h| h.symbolize_keys! }
      @provider = config[:provider]
      @ssl      = config[:ssl]
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
end