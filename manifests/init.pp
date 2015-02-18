# == Class: knot
#
# Full description of class knot here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
# === Examples
#
#  class { 'knot':
#    sample_parameter => 'sample value',
#  }
#
# === Authors
#
# tobru
#
# === Copyright
#
# Copyright 2015 tobru
#
class knot (
  $package_ensure       = $::knot::params::package_ensure,
  $package_name         = $::knot::params::package_name,
  $package_distcodename = $::knot::params::package_distcodename,
  $manage_package_repo  = $::knot::params::manage_package_repo,
  $service_name         = $::knot::params::service_name,
  $service_enable       = $::knot::params::service_enable,
  $service_ensure       = $::knot::params::service_ensure,
  $service_manage       = $::knot::params::service_manage,
  $config_file          = $::knot::params::config_file,
  $system               = $::knot::params::system,
  $log                  = $::knot::params::log,
  $interfaces           = $::knot::params::interfaces,
  $control              = $::knot::params::control,
  $keys                 = undef,
  $remotes              = undef,
  $groups               = undef,
) inherits ::knot::params {

  # validate parameters here:
  # validate_absolute_path, validate_bool, validate_string, validate_hash
  # validate_array, ... (see stdlib docs)
  if $keys { validate_hash($keys) }
  if $remotes { validate_hash($remotes) }
  if $groups { validate_hash($groups) }

  class { '::knot::install': } ->
  class { '::knot::config': } ~>
  class { '::knot::service': }

  contain ::knot::install
  contain ::knot::config
  contain ::knot::service

}
