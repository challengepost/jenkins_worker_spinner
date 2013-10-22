module JenkinsWorkerSpinner
  class Mailer
    def initialize(config = Config.new)
      @config = config
    end

    def send(data = {})
      cio.track(CIO_CLIENT_ID, CIO_EMAIL_NAME, data) unless config.local
    end

    private

    CIO_EMAIL_NAME = "instantiated_digital_ocean_instance"
    CIO_CLIENT_ID = 1

    attr_reader :config

    def cio
      @cio ||= begin
        Customerio::Client.new(config.cio_site_id, config.cio_secret_key).tap do |cio|
          cio.identify(id: CIO_CLIENT_ID, email: config.destination_email, first_name: config.destination_first_name)
        end
      end
    end

  end
end
