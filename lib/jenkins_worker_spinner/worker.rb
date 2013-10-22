module JenkinsWorkerSpinner
  class Worker
    def initialize(config = Config.new)
      @config = config
      @mailer = Mailer.new(config)
      prepare
    end

    # EVENTS:
    # https://api.digitalocean.com/events/xxxx
    # {"status":"OK","event":{"action_status":null,"droplet_id":xxxx,"event_type_id":1,"id":xxxx,"percentage":"5"}}
    # {"status":"OK","event":{"action_status":"done","droplet_id":xxxx,"event_type_id":1,"id":xxxx,"percentage":"100"}}

    # On success:
    # <RecursiveOpenStruct status="OK",
    #   droplet={
    #   "id"=>xxx, "name"=>"bigman",
    #   "image_id"=>xxx, "size_id"=>xxx,
    #   "event_id"=>xxx
    #   }
    # >
    def instantiate_worker
      response = Digitalocean::Droplet.create(new_instance_attributes) unless worker_id.present?
      if response.droplet.event_id.present?
        puts "Scheduled #{response.inspect}"
      else
        STDERR.puts "Failed creating droplet: #{response.inspect}"
      end
    end

    def worker_ip
      unless worker_id.present?
        STDERR.puts "No droplet with name #{config.do_name} exists!"
        return
      end

      response = Digitalocean::Droplet.retrieve(worker_id)
      droplet = response.droplet

      puts <<-EOF
#{droplet.name}: #{droplet.ip_address}
      EOF

      mailer.send(new_ip_address: droplet.ip_address, name: droplet.name)
    end

    # On success:
    # <RecursiveOpenStruct status="OK", event_id=xxx>
    # NEED TO ADD Event API!!!
    # On failure:
    #
    def kill_worker
      response = Digitalocean::Droplet.destroy(worker_id) if worker_id.present?
      STDERR.puts "Error, #{response.error_message}" unless response.status == "OK"
    end

    private

    attr_reader :config, :mailer

    def new_instance_attributes
      {
        name: config.do_name,
        size_id: config.do_size_id,
        image_id: config.do_image_id,
        region_id: config.do_region_id,
        ssh_key_ids: ssh_key_ids
      }
    end

    def droplets
      @droplets ||= Digitalocean::Droplet.all.droplets
    end

    def ssh_key_ids
      return config.do_ssh_key_ids.join(',') if config.do_ssh_key_ids.is_a?(Array)
      config.do_ssh_key_ids
    end

    def droplet_id_by_name(name)
      droplets.map {|d| [d.name, d.id] }.select { |e| e[0] == name }.flatten[1]
    end

    def worker_id
      @worker_id ||= droplet_id_by_name(config.do_name)
    end

    def prepare
      Digitalocean.api_key = config.do_api_key
      Digitalocean.client_id = config.do_client_id
    end
  end
end
