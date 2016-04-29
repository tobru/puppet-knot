# == Class: knot
#
# Main class for the knot module. Every parameter needs to be passed to
# this class.
#
# === Parameters
#
# See main documentation in README.md
#
# === Examples
#
# See main documentation in README.md
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
  # package installation handling
  $manage_package_repo = false,
  $package_ensure = 'installed',
  $package_name = $::knot::params::package_name,
  $package_repo_key = $::knot::params::package_repo_key,
  $package_repo_key_src = $::knot::params::package_repo_key_src,
  $package_repo_location = $::knot::params::package_repo_location,
  $package_repo_repos = $::knot::params::package_repo_repos,
  # system service configuration
  $manage_user = true,
  $service_enable = true,
  $service_ensure = 'running',
  $service_group = $::knot::params::service_group,
  $service_manage = true,
  $service_name = $::knot::params::service_name,
  $service_restart = '/usr/sbin/knotc reload',
  $service_status = '/usr/sbin/knotc status',
  $service_user = $::knot::params::service_user,
  # knot specific configuration
  $default_storage = '/var/lib/knot',
  $main_config_file = '/etc/knot/knot.conf',
  $manage_zones = true,
  $template_parameter = 'template',
  $zone_defaults = {},
  $zones_config_file = '/etc/knot/zones.conf',
  $zones_config_template = 'knot/zones.conf.erb',
  # knot configuration sections
  $acls = {},
  $control = {},
  $keys = {},
  $log = { 'syslog' => { 'any' => 'info'} },
  $modules = {},
  $remotes = {},
  $server = { 'listen' => [ '0.0.0.0@53', '::@53' ] },
  $templates = {},
  $zones = {},
  # DNSSEC
  $dnssec_enable = true,
  $dnssec_keydir = '/var/lib/knot/kasp',
  $signing_policies = {}
) inherits ::knot::params {

  # package installation handling
  validate_bool($manage_package_repo)
  validate_string($package_name)
  validate_string($package_repo_key)
  validate_string($package_repo_key_src)
  validate_string($package_repo_location)
  validate_string($package_repo_repos)

  # system service configuration
  validate_bool($manage_user)
  validate_bool($service_enable)
  validate_re($service_ensure, '^stopped|false|running|true$')
  validate_string($service_group)
  validate_bool($service_manage)
  validate_string($service_name)
  validate_string($service_restart)
  validate_string($service_status)
  validate_string($service_user)

  # knot specific configuration
  validate_absolute_path($default_storage)
  validate_absolute_path($main_config_file)
  validate_bool($manage_zones)
  validate_string($template_parameter)
  validate_hash($zone_defaults)
  validate_absolute_path($zones_config_file)
  validate_string($zones_config_template)

  # knot configuration sections
  validate_hash($acls)
  validate_hash($control)
  validate_hash($keys)
  validate_hash($log)
  validate_hash($modules)
  validate_hash($remotes)
  validate_hash($server)
  validate_hash($templates)
  validate_hash($zones)

  # DNSSEC
  validate_bool($dnssec_enable)
  validate_absolute_path($dnssec_keydir)
  validate_hash($signing_policies)

  class { '::knot::install': } ->
  class { '::knot::config': } ~>
  class { '::knot::service': }

  contain ::knot::install
  contain ::knot::config
  contain ::knot::service

}
