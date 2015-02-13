# == Class knot::config
#
# This class is called from knot for service config.
#
class knot::config inherits knot {

  file { $config_file:
    ensure  => file,
    content => template('knot/knot.conf.erb'),
  }

}
