# == Class knot::config
#
# This class is called from knot for service config.
#
class knot::config {

  # get variables from the toplevel manifest for usage in the template
  $config_file = $::knot::main_config_file
  $default_storage = $::knot::default_storage
  $dnssec_enable = $::knot::dnssec_enable
  $dnssec_keydir = $::knot::dnssec_keydir
  $manage_zones = $::knot::manage_zones
  $service_group = $::knot::service_group
  $service_user = $::knot::service_user
  $zone_defaults = $::knot::zone_defaults
  $zones_config_file = $::knot::zones_config_file
  $zones_config_template = $::knot::zones_config_template

  # knot configuration sections
  $acls = $::knot::acls
  $control = $::knot::control
  $keys = $::knot::keys
  $modules = $::knot::modules
  $policies = $::knot::policies
  $remotes = $::knot::remotes
  $templates = $::knot::templates
  $zones = $::knot::zones

  # merge two hashes:
  # * the configuration hash from the user calling $knot::config_*
  # * the hash containing the default values in $knot::params::config_*
  # When there is a duplicate key, the key in the user specified hash (rightmost) "wins"
  # Note: this is not a deep merge, it merges only the toplevel keys
  $server = merge($::knot::params::server, $::knot::server)
  $log = merge($::knot::params::log, $::knot::log)

  if $::knot::manage_user {
    user { $::knot::service_user:
      ensure  => present,
      comment => 'Knot Service User',
      home    => $::knot::default_storage,
      shell   => '/bin/false',
      system  => true,
    }
  }

  file { $config_file:
    ensure  => file,
    owner   => $service_user,
    group   => $service_group,
    content => template('knot/knot.conf.erb'),
  }
  file { $default_storage:
    ensure  => directory,
    owner   => $service_user,
    group   => $service_group,
    recurse => true,
  }

  if $manage_zones == false {
    file { $zones_config_file:
        ensure => present,
        owner  => $service_user,
        group  => $service_group,
    }
  } else {
    file { $zones_config_file:
      ensure  => file,
      owner   => $service_user,
      group   => $service_group,
      content => template($zones_config_template);
    }
  }

}
