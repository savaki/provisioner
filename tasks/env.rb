require 'rubygems'
require 'aws-sdk'

# allow for easy assignment of environment variables
#
def env default, *names
  value = nil
  names.each do |name|
    if ENV[name] =~ /\S/
      value = ENV[name]
      break
    end
  end

  value = default unless value =~ /\S/
  value
end

APP_NAME              = ENV["APP_NAME"]
APP_ENV               = ENV["APP_ENV"]

ARTIFACT              = env("baseami.json", "ARTIFACT")

# settings specific to the AMI
#
AMI_REGION            = env("us-west-2", "AMI_REGION")
AMI_INSTANCE_TYPE     = env("m1.medium", "AMI_INSTANCE_TYPE")
AMI_AZ                = env("us-west-2b", "AMI_AZ")
AMI_ELB               = env("#{APP_NAME}-#{APP_ENV}", "AMI_ELB")
AMI_KEY_PAIR          = env(APP_NAME, "AMI_KEY_PAIR")
AMI_SECURITY_GROUP    = env(APP_NAME, "AMI_SECURITY_GROUP")

# aws access key with ridiculously restrictive permissions
#
AMI_ACCESS_KEY_ID     = ENV["AMI_ACCESS_KEY_ID"]
AMI_SECRET_ACCESS_KEY = ENV["AMI_SECRET_ACCESS_KEY"]


AWS_ACCESS_KEY_ID     = ENV["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = ENV["AWS_SECRET_ACCESS_KEY"] 


VERSION               = env("SNAPSHOT-#{Time.now.to_i}", "GO_PIPELINE_COUNTER")


raise "APP_NAME not set!"              unless APP_NAME               =~ /\S/
raise "APP_ENV not set!"               unless APP_ENV                =~ /\S/

raise "AWS_ACCESS_KEY_ID not set!"     unless AWS_ACCESS_KEY_ID      =~ /\S/
raise "AWS_SECRET_ACCESS_KEY not set!" unless AWS_SECRET_ACCESS_KEY  =~ /\S/

raise "AMI_ACCESS_KEY_ID not set!"     unless AMI_ACCESS_KEY_ID      =~ /\S/
raise "AMI_SECRET_ACCESS_KEY not set!" unless AMI_SECRET_ACCESS_KEY  =~ /\S/

unless ["development", "staging", "production"].include? APP_ENV
  raise "AMI_ENV contains an invalid environment, #{AMI_ENV}.  valid environments: development, staging, production" 
end

AWS.config({
  :access_key_id     => AWS_ACCESS_KEY_ID, 
  :secret_access_key => AWS_SECRET_ACCESS_KEY
})

# displays the configuration
#
def config
  value <<EOF

APP_NAME              = #{APP_NAME}
APP_ENV               = #{APP_ENV}

ARTIFACT              = #{ARTIFACT}

AMI_REGION            = #{AMI_REGION}
AMI_INSTANCE_TYPE     = #{AMI_INSTANCE_TYPE}
AMI_AZ                = #{AMI_AZ}
AMI_ELB               = #{AMI_ELB}
AMI_KEY_PAIR          = #{AMI_KEY_PAIR}
AMI_SECURITY_GROUP    = #{AMI_SECURITY_GROUP}

VERSION               = #{VERSION}

EOF
  value
end

