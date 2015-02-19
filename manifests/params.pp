# == Class knot::params
#
# This class is meant to be called from knot.
# It sets variables according to platform.
#
class knot::params {
  case $::osfamily {
    'Debian': {
      $package_name  = 'knot'
      $service_name  = 'knot'
      $service_user  = 'knot'
      $service_group = 'knot'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # package parameters
  $package_ensure = installed
  $package_distcodename = $::lsbdistcodename
  $manage_package_repo = false

  # service parameters
  $service_enable = true
  $service_ensure = running
  $service_manage = true

  # knot configuration defaults
  # coming from the package installation
  $main_config_file = '/etc/knot/knot.conf'
  $zones_config_file = '/etc/knot/zones.conf'
  $system = {
    identity => 'on',
    version  => 'on',
  }
  $log = {
    syslog => {
      any  => 'info'
    },
    stderr => {
      any  => 'warning'
    }
  }
  $interfaces = {
    all_ipv4  => {
      address => '0.0.0.0',
      port    => 53,
    },
    all_ipv6  => {
      address => '[::]',
      port    => 53,
    }
  }
  $control = {
    listen-on => 'knot.sock'
  }
  $zone_storage = '/var/lib/knot'
  $dnssec_keydir = '/etc/knot/dnssec_keys.d'

}
