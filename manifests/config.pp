# == Class knot::config
#
# This class is called from knot for service config.
#
class knot::config {

  # get variables from the toplevel manifest for usage in the template
  $config_file   = $knot::main_config_file
  $zones_file    = $knot::zones_config_file
  $keys          = $knot::keys
  $remotes       = $knot::remotes
  $groups        = $knot::groups
  $zone_storage  = $knot::zone_storage
  $dnssec_enable = $knot::dnssec_enable
  $dnssec_keydir = $knot::dnssec_keydir

  # merge two hashes:
  # * the configuration hash from the user calling $knot::config_*
  # * the hash containing the default values in $knot::params::config_*
  # When there is a duplicate key, the key in the user specified hash (rightmost) "wins"
  # Note: this is not a deep merge, it merges only the toplevel keys
  $system       = merge($knot::params::system, $knot::system)
  $zone_options = merge($knot::params::zone_options, $knot::zone_options)
  $log          = merge($knot::params::log, $knot::log)
  $interfaces   = merge($knot::params::interfaces, $knot::interfaces)
  $control      = merge($knot::params::control, $knot::control)

  file {
    $config_file:
      ensure  => file,
      content => template('knot/knot.conf.erb');
    $zones_file:
      ensure  => file,
      content => template('knot/zones.conf.erb');
    $zone_storage:
      ensure => directory;
  }

  if $dnssec_enable {
    file { $dnssec_keydir:
      ensure => directory,
    }
  }

}
