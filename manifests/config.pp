# == Class knot::config
#
# This class is called from knot for service config.
#
class knot::config {

  # get variables from the toplevel manifest for usage in the template
  $keys    = $knot::keys
  $remotes = $knot::remotes
  $groups  = $knot::groups

  # merge two hashes:
  # * the configuration hash from the user calling $knot::config_*
  # * the hash containing the default values in $knot::params::config_*
  # When there is a duplicate key, the key in the user specified hash "wins"
  # Note: this is not e deep merge, merges only the toplevel keys
  $system     = merge($knot::params::system, $knot::system)
  $log        = merge($knot::params::log, $knot::log)
  $interfaces = merge($knot::params::interfaces, $knot::interfaces)
  $control    = merge($knot::params::control, $knot::control)

  file { $knot::config_file:
    ensure  => file,
    content => template('knot/knot.conf.erb'),
  }

}
