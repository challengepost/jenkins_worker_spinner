require "rubygems"
require "active_support/core_ext/object/blank"
require "active_support/hash_with_indifferent_access"
require "customerio"
require "digitalocean"
require "optparse"

module JenkinsWorkerSpinner
  autoload :CLI,    'jenkins_worker_spinner/cli'
  autoload :Config, 'jenkins_worker_spinner/config'
  autoload :Mailer, 'jenkins_worker_spinner/mailer'
  autoload :Worker, 'jenkins_worker_spinner/worker'
end
