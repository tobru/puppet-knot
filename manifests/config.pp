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
  $signing_policies = $::knot::signing_policies
  $zone_defaults = $::knot::zone_defaults
  $zone_options = $::knot::zone_options
  $zones_config_file = $::knot::zones_config_file

  # knot configuration sections
  $acls = $::knot::acls
  $control = $::knot::control
  $keys = $::knot::keys
  $modules = $::knot::modules
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
    file { $zones_file:
        ensure => present,
        owner  => $service_user,
        group  => $service_group,
    }
  } else {
    file { $zones_file:
      ensure  => file,
      owner   => $service_user,
      group   => $service_group,
      content => template('knot/zones.conf.erb');
    }
    if $dnssec_enable {
      $_all_zones = keys($zones)
      ::knot::zone_policy { $_all_zones:
        zones         => $zones,
        templates     => $templates,
        dnssec_keydir => $dnssec_keydir,
        user          => $service_user,
        group         => $service_group,
        require       => Exec['initialize_kasp'],
      }
    }
  }

  if $dnssec_enable {
    $_signing_policy_names = keys($signing_policies)

    file { $dnssec_keydir:
      ensure  => directory,
      owner   => $service_user,
      group   => $service_group,
      recurse => true,
    } ->
    exec { 'initialize_kasp':
      command => '/usr/sbin/keymgr init',
      creates => "${dnssec_keydir}/keys",
      cwd     => $dnssec_keydir,
      user    => $service_user,
      group   => $service_group,
      require => Package[$::knot::package_name],
    } ->
    ::knot::signing_policy { $_signing_policy_names:
      data          => $signing_policies,
      dnssec_keydir => $dnssec_keydir,
      user          => $service_user,
      group         => $service_group,
    }
  }

}
