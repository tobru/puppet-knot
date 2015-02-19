# == Class knot::install
#
# This class is called from knot for install.
#
class knot::install {

  $package_name         = $knot::package_name
  $package_ensure       = $knot::package_ensure
  $manage_package_repo  = $knot::manage_package_repo
  $package_distcodename = $knot::package_distcodename

  if $manage_package_repo {
    apt::source { 'knot_official':
      comment     => 'Official repository for knot provided by knot-dns.cz',
      location    => 'http://deb.knot-dns.cz/debian/',
      release     => $package_distcodename,
      repos       => 'main',
      key         => '4A7A714D',
      key_source  => 'http://deb.knot-dns.cz/debian/apt.key',
      include_src => true,
      include_deb => true,
    } ->
    package { $package_name:
      ensure => $package_ensure,
    }
  } else {
    package { $package_name:
      ensure => $package_ensure,
    }
  }
}
