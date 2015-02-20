# == Class knot::install
#
# This class is called from knot for install.
#
class knot::install {

  $package_name          = $knot::package_name
  $package_ensure        = $knot::package_ensure
  $manage_package_repo   = $knot::manage_package_repo
  $package_repo_location = $knot::package_repo_location
  $package_repo_repos    = $knot::package_repo_repos
  $package_repo_key      = $knot::package_repo_key
  $package_repo_key_src  = $knot::package_repo_key_src

  if $manage_package_repo {
    apt::source { 'knot_official':
      comment     => 'Official repository for knot provided by knot-dns.cz',
      location    => $package_repo_location,
      release     => $::lsbdistcodename,
      repos       => $package_repo_repos,
      key         => $package_repo_key,
      key_source  => $package_repo_key_src,
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
