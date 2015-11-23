# == Class knot::install
#
# This class is called from knot for install.
#
class knot::install {

  $package_name          = $::knot::package_name
  $package_ensure        = $::knot::package_ensure
  $manage_package_repo   = $::knot::manage_package_repo

  # only do repo management when on a Debian-like system
  if $manage_package_repo and $::osfamily == 'Debian' {
    $package_repo_location = $::knot::package_repo_location
    $package_repo_repos    = $::knot::package_repo_repos
    $package_repo_key      = $::knot::package_repo_key
    $package_repo_key_src  = $::knot::package_repo_key_src

    ::apt::source { 'knot':
      comment     => 'Official repository for Knot DNS provided by knot-dns.cz',
      location    => $package_repo_location,
      release     => $::lsbdistcodename,
      repos       => $package_repo_repos,
      key         => {
        'id' => $package_repo_key,
        'source' => $package_repo_key_src,
      },
      include     => {
        'deb' => true,
        'src' => false,
      },
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
