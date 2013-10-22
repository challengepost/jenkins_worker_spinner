module JenkinsWorkerSpinner
  class Config

    def initialize(options = HashWithIndifferentAccess.new, run_load = true)
      self.load(options) if run_load
    end

    # This is responsible of loading the config object
    def load(options = HashWithIndifferentAccess.new)
      config = load_config_file(options[:config])
      import_config(config, options)
    end

    def store_file
      return File.expand_path(".", store["filename"]) if store
      nil
    end

    def config
      @config
    end

    private

    # This will load the passed in config object into the config attribute
    def import_config(cnf = HashWithIndifferentAccess.new, options = HashWithIndifferentAccess.new)
      cnf["verbose"] = options[:verbose] unless options[:verbose].nil?
      @config = cnf.merge(options)
    end

    # This is responsible to return a hash with the contents of a YAML file
    def load_config_file(config_file = nil)
      curated_file = nil

      if config_file
        f = File.expand_path(config_file)
        if File.exists?(f)
          curated_file = f
        else
          raise "Supplied config file (#{config_file}) doesn't seem to exist"
        end
      else
        locations_to_try.each do |possible_conf_file|
          f = File.expand_path(possible_conf_file)
          if File.exists?(f)
            curated_file = f
            break
          end
        end

        if curated_file.nil?
          return HashWithIndifferentAccess.new
        end
      end

      YAML.load_file(curated_file).tap do |config|
        raise "This is an invalid configuration file!" unless config.class == Hash
      end
    end

    def locations_to_try
        %w(
          ~/.config/jenkins_worker_spinner/config.yml
          /etc/jenkins_worker_spinner/config.yml
          /usr/local/etc/jenkins_worker_spinner/config.yml
        )
    end

    def method_missing(method_name, *args, &block)
      option_exists(method_name) ? get_option(method_name) : super
    end

    def respond_to_missing?(method_name)
      option_exists(method_name)
    end

    def option_exists(option_as_symbol)
      option = option_as_symbol.to_s
      config.has_key?(option) || ENV[option.upcase].present?
    end

    def get_option(option_as_symbol)
      option = option_as_symbol.to_s
      (ENV[option.upcase] || config[option]).tap do |value|
        return false if value == "false"
      end
    end

  end
end
