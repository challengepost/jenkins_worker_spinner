module JenkinsWorkerSpinner
  class CLI
    def self.instantiate_worker
      self.new.instantiate_worker
    end

    def self.kill_worker
      self.new.kill_worker
    end

    def self.worker_ip
      self.new.worker_ip
    end

    def initialize
      process_command_line_options
      @config = Config.new(options)
      @worker = Worker.new(config)
    end

    def instantiate_worker
      Worker.new(config).instantiate_worker
    end

    def kill_worker
      Worker.new(config).kill_worker
    end

    def worker_ip
      Worker.new(config).worker_ip
    end

    private

    attr_reader :options, :config, :worker

    def process_command_line_options
      @options = HashWithIndifferentAccess.new

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options]"

        opts.on("-c", "--config CONFIG", "Override configuration file location") do |c|
          options[:config] = c
        end

        opts.on("-d", "--destination DESTINATION", "Whom to send results") do |d|
          options[:destination] = d
        end

        opts.on("-a", "--api_key API_KEY") do |k|
          options[:api_key] = k
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end

        opts.on("-l", "--local", "Don't email results. Just echo them") do |l|
          options[:local] = l
        end

        opts.on("-w", "--when", "Specify when to look for events") do |w|
          options[:when] = w
        end
      end.parse!
    end
  end
end

