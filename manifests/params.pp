# == Class knot::params
#
# This class is meant to be called from knot.
# It sets variables according to platform.
#
class knot::params {

  # OS specific parameters
  case $::osfamily {
    'Debian': {
      $package_name = 'knot'
      $service_name = 'knot'
      $service_user = 'knot'
      $service_group = 'knot'
      # Choose repo location according to LSB distribution id
      # Only used when manage_package_repo and on a Debian based OS
      case $::lsbdistid {
        'Debian': {
          $package_repo_location = 'http://deb.knot-dns.cz/debian/'
          $package_repo_repos = 'main'
          $package_repo_key = 'DF3D585DB8F0EB658690A554AC0E47584A7A714D'
          $package_repo_key_src = 'http://deb.knot-dns.cz/debian/apt.key'
        }
        'Ubuntu': {
          $package_repo_location = 'http://ppa.launchpad.net/cz.nic-labs/knot-dns/ubuntu'
          $package_repo_repos = 'main'
          $package_repo_key = '52463488670E69A092007C24F2331238F9C59A45'
          $package_repo_key_src = undef
        }
        default: {
          fail("LSB distid ${::lsbdistid} not supported")
        }
      }
    }
    'RedHat': {
      $package_name = 'knot'
      $service_name = 'knot'
      $service_user = 'knot'
      $service_group = 'knot'
      $package_repo_location = undef
      $package_repo_repos = undef
      $package_repo_key = undef
      $package_repo_key_src = undef
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  ## Default parameters
  $server = {
    'listen' => [ '0.0.0.0@53', '::@53' ]
  }
  $log = {
    'syslog' => {
      'any'  => 'info'
    },
  }

}
