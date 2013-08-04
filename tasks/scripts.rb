require File.expand_path(File.dirname(__FILE__) + '/env')
require 'erb'

# config is used by the erb file
def config
  {
    :APP_NAME              => APP_NAME,
    :APP_ENV               => APP_ENV,
    :AWS_ACCESS_KEY_ID     => AMI_ACCESS_KEY_ID,
    :AWS_SECRET_ACCESS_KEY => AMI_SECRET_ACCESS_KEY
  }
end

# user_data returns a string containing the script we'd like to install for the user_data
def user_data 
  erb = ERB.new(File.open("scripts/user_data.sh.erb").read)
  erb.result binding
end

