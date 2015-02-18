# == Class knot::config
#
# This class is called from knot for service config.
#
class knot::config {

  # merge two hashes:
  # * the configuration hash from the user calling $knot::config_system
  # * the hash containing the default values in $knot::params::config_system
  # When there is a duplicate key, the key in the user specified hash "wins"
  $config_system = merge($knot::params::config_system, $knot::config_system)

  file { $knot::config_file:
    ensure  => file,
    content => template('knot/knot.conf.erb'),
  }

}
