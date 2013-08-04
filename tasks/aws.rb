require File.expand_path(File.dirname(__FILE__) + '/env')
require File.expand_path(File.dirname(__FILE__) + '/scripts')

# the name of the launch config file we want
def launch_config_name 
  "#{APP_NAME}-build-#{VERSION}-#{APP_ENV}"
end

# create a new auto scaling group
def new_auto_scaling 
   AWS::AutoScaling.new(:auto_scaling_endpoint => "autoscaling.#{AMI_REGION}.amazonaws.com")
end

# convenience method to 
#
#   (a) create a new asg for an environment and 
#   (b) delete any prior asgs for the env
#
def deploy_asg config
  launch_config_name = create_new_asg config
  delete_old_asg config, launch_config_name
end

# create a new asg along with an associated launch configuration for that asg
def create_new_asg config
  delete_launch_configs

  auto_scaling  = new_auto_scaling

  #
  # 1. create the launh configuration
  #
  options = {
    :security_groups  => [AMI_SECURITY_GROUP],
    :key_pair         => AMI_KEY_PAIR,
    :user_data        => user_data
  }

  launch_config = auto_scaling.launch_configurations.create(
    launch_config_name, 
    config["ami"],
    AMI_INSTANCE_TYPE,
    options
  )

  #
  # now create the asg
  #

  tags = [
    {:key => "server", :value => APP_NAME},
    {:key => "build",  :value => VERSION},
    {:key => "env",    :value => APP_ENV}
  ]

  options = {
    :load_balancers       => [AMI_ELB],
    :launch_configuration => launch_config,
    :availability_zones   => [AMI_AZ],
    :min_size             => 1,
    :max_size             => 1,
    :tags                 => tags
  }

  puts "creating asg"
  puts "\toptions => #{options}"
  puts "\ttags    => #{tags}"
  auto_scaling.groups.create(launch_config_name, options)
end

# help method to easily extract out the value of a specific key
#
def tag_value tags, key
  tags.to_ary.each do |i|
    return i[:value] if i[:key] == key
  end
  return nil
end

# delete the old asgs for this environment.  an old asg is any asg with the same server and env name that has a
# different launch_config_name than the one specified
#
def delete_old_asg config, launch_config_name
  auto_scaling = new_auto_scaling
  auto_scaling.groups.each do |group|
    server = tag_value(group.tags, "server")
    if server != config["server"]
      next 
    end

    env = tag_value(group.tags, "env")
    if env != config["env"]
      next 
    end

    if group.name != launch_config_name.name
      puts "deleting instance group, #{group.name} => #{launch_config_name.name}"
      delete_asg group.name
    end
  end
end

# delete the asg with the specified name
def delete_asg name
  auto_scaling  = new_auto_scaling
  groups        = auto_scaling.groups
  raise "unable to delete asg, #{name}.  asg not found!" if groups[name].nil? 

  asg = groups[name]

  puts "deleting asg, #{asg.name}"
  asg.delete({:force => true})
  delete_launch_configs
end

# delete all the launch configs that don't have at least 1 running asg of the same name
def delete_launch_configs
  auto_scaling  = new_auto_scaling
  groups        = auto_scaling.groups
  auto_scaling.launch_configurations.each do |config|
    if groups[config.name].nil?
      puts "deleting asg launch configuration, #{config.name}"
      config.delete()
    end
  end
end

# utility to list the existing asgs
#
def list_asgs
  # collect the list of running instances in this zone
  ec2       = AWS::EC2.new
  region    = ec2.regions[AMI_REGION]
  instances = region.instances.select { |i| i.tags.to_h["server"] == APP_NAME }

  # now find the list of running asgs
  format    = "%-32s %s"
  puts
  puts format % ["Instance Groups", "Tags"]
  puts format % ["-" * 32, "-" * 60]
  auto_scaling  = new_auto_scaling
  count         = 0
  auto_scaling.groups.each do |group|
    count = count + 1
    puts format  % [group.name, tag_value(group.tags, "env")]

    instances.each do |i|
      if i.tags.to_h["env"] == tag_value(group.tags, "env")
        puts "\t%s %-13s %s" % [i.id, i.status, i.dns_name]
      end
    end
    puts
  end
  puts format % ["-" * 32, "-" * 60]
  puts "Found #{count} ASGs"
  puts
end

def view_asg 
  auto_scaling  = new_auto_scaling
  auto_scaling.groups.each do |group|
    puts <<EOF

Name:  #{group.name}
Size:  min => #{group.min_size}, max => #{group.max_size}
ELB:   #{group.load_balancer_names.to_ary}
Tag:   #{group.tags.to_ary}
Zones: #{group.availability_zone_names.to_ary}
Date:  #{group.created_time}
EOF
  end
end
