#!/usr/bin/env rake

$:.push File.expand_path("../lib", __FILE__)

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

desc "Run rspec by default"
task default: :spec
