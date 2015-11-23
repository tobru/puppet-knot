# == Class knot::install
#
# This class is called from knot for install.
#
class knot::install {

  # only do repo management when on a Debian-like system
  if ($::knot::manage_package_repo) and ($::osfamily == 'Debian') {
    ::apt::source { 'knot':
      comment     => 'Official repository for Knot DNS provided by knot-dns.cz',
      location    => $::knot::package_repo_location,
      release     => $::lsbdistcodename,
      repos       => $::knot::package_repo_repos,
      key         => {
        'id' => $::knot::package_repo_key,
        'source' => $::knot::package_repo_key_src,
      },
      include     => {
        'deb' => true,
        'src' => false,
      },
    } ->
    package { $::knot::package_name:
      ensure  => $::knot::package_ensure,
      require => Exec['apt_update'],
    }
  } else {
    package { $::knot::package_name:
      ensure => $::knot::package_ensure,
    }
  }
}
