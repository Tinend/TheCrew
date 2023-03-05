# frozen_string_literal: true

begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('native')
rescue LoadError => e
  warn "Couldn't create extension task: #{e}"
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec, [] => :compile)

  task default: :spec
rescue LoadError
  warn "Couldn't create spec task: #{e}"
end
