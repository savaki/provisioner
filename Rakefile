require File.expand_path(File.dirname(__FILE__) + '/tasks/aws')
require 'yaml'

def load_config 
  artifact = YAML.load_file(ARTIFACT)

  raise "artifact, #{ARTIFACT}, missing entry, ami"   unless artifact["ami"]   =~ /\S/
  raise "artifact, #{ARTIFACT}, missing entry, build" unless artifact["build"] =~ /\S/

  {
    "server" => APP_NAME,
    "env"    => APP_ENV,
    "ami"    => artifact["ami"],
    "build"  => artifact["build"]
  }
end

task :default do
end

desc "clean"
task :clean do
  system "rm -f *.deb"
  system "rm -f artifact.json"
  system "rm -rf packer_cache"
  system "rm -rf dist"
end

namespace :asg do
  desc "deploy application to aws"
  task :deploy do 
    config = load_config
    deploy_asg config
  end

  desc "delete a specific asg along with the instances associated with it.  this will also delete the launch configuration"
  task :delete, :name do |t, args|
    name = args["name"]
    delete_asg name
  end

  desc "list asgs"
  task :list do
    list_asgs
  end
end

