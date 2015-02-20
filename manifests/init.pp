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
# Tobias Brunner <tobias@tobru.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner
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
  $service_user         = $::knot::params::service_user,
  $service_group        = $::knot::params::service_group,
  $main_config_file     = $::knot::params::main_config_file,
  $zones_config_file    = $::knot::params::zones_config_file,
  $system               = $::knot::params::system,
  $log                  = $::knot::params::log,
  $interfaces           = $::knot::params::interfaces,
  $control              = $::knot::params::control,
  $keys                 = undef,
  $remotes              = undef,
  $groups               = undef,
  $dnssec_enable        = $::knot::params::dnssec_enable,
  $dnssec_keydir        = $::knot::params::dnssec_keydir,
  $zone_storage         = $::knot::params::zone_storage,
  $zone_defaults        = undef,
  $zone_options         = undef,
  $zones                = {},
) inherits ::knot::params {

  # mandatory parameters
  validate_re($package_ensure, '^installed|present|absent|purged|held|latest$')
  validate_string($package_name)
  validate_string($package_distcodename)
  validate_bool($manage_package_repo)
  validate_string($service_name)
  validate_bool($service_enable)
  validate_re($service_ensure, '^stopped|false|running|true$')
  validate_bool($service_manage)
  validate_string($service_user)
  validate_string($service_group)
  validate_string($main_config_file)
  validate_string($zones_config_file)
  validate_hash($system)
  validate_hash($log)
  validate_hash($interfaces)
  validate_hash($control)
  validate_string($zone_storage)
  validate_bool($dnssec_enable)
  validate_string($dnssec_keydir)
  validate_hash($zones)

  # optional parameters
  if $keys { validate_hash($keys) }
  if $remotes { validate_hash($remotes) }
  if $groups { validate_hash($groups) }
  if $zone_options { validate_hash($zone_options) }
  if $zone_defaults { validate_hash($zone_defaults) }

  class { '::knot::install': } ->
  class { '::knot::config': } ~>
  class { '::knot::service': }

  contain ::knot::install
  contain ::knot::config
  contain ::knot::service

}
