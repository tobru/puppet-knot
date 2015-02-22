# == Class knot::params
#
# This class is meant to be called from knot.
# It sets variables according to platform.
#
class knot::params {

  # OS specific parameters
  case $::osfamily {
    'Debian': {
      $package_name          = 'knot'
      $service_name          = 'knot'
      $service_user          = 'knot'
      $service_group         = 'knot'
      # Choose repo location according to LSB distribution id
      # Only used when manage_package_repo and on a Debian based OS
      case $::lsbdistid {
        'Debian': {
          $package_repo_location = 'http://deb.knot-dns.cz/debian/'
          $package_repo_repos    = 'main'
          $package_repo_key      = '4A7A714D'
          $package_repo_key_src  = 'http://deb.knot-dns.cz/debian/apt.key'
        }
        'Ubuntu': {
          $package_repo_location = 'http://ppa.launchpad.net/cz.nic-labs/knot-dns/ubuntu'
          $package_repo_repos    = 'main'
          $package_repo_key      = 'F9C59A45'
          $package_repo_key_src  = undef
        }
        default: {
          fail("LSB distid ${::lsbdistid} not supported")
        }
      }
    }
    'RedHat': {
      $package_name          = 'knot'
      $service_name          = 'knot'
      $service_user          = 'knot'
      $service_group         = 'knot'
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  # package parameters
  $package_ensure = present
  $manage_package_repo = false

  # service parameters
  $service_enable = true
  $service_ensure = running
  $service_manage = true

  # knot configuration defaults
  # coming from the package installation
  $dnssec_enable = false
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
