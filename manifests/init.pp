# == Class: knot
#
# Main class for the knot module. Every parameter needs to be passed to
# this class.
#
# === Parameters
#
# [*manage_package_repo*]
#   Default: false. If set to true, make sure the puppetlabs/apt module is available
#   as it adds the knot-dns.cz repo to the APT sources
#
# [*package_ensure*]
#   Default: installed. See Puppet type 'package' documentation
#
# [*package_name*]
#   Default: On Debian 'knot'. Package name to install knot
#
# [*package_repo_key*]
#   Default: Depends on $::lsbdistid, see params.pp
#   Only used when $manage_package_repo is true.
#   Signing key of the packages
#
# [*package_repo_key_src*]
#   Default: Depends on $::lsbdistid, see params.pp
#   Only used when $manage_package_repo is true.
#   Source of the package signing public key
#
# [*package_repo_location*]
#   Default: Depends on $::lsbdistid, see params.pp
#   Only used when $manage_package_repo is true.
#   Location of the package repository
#
# [*package_repo_repos*]
#   Default: Depends on $::lsbdistid, see params.pp
#   Only used when $manage_package_repo is true.
#   Repos used on the repository location
#
# [*manage_user*]
#   Default: true. Manages the Puppet user resource for the user $service_user
#
# [*service_enable*]
#   Default: true. See Puppet type 'service' documentation
#
# [*service_ensure*]
#   Default: running. See Puppet type 'service' documentation
#
# [*service_group*]
#   Default: On Debian 'knot'. Group under which the knot daemon runs
#
# [*service_manage*]
#   Default: true. If set to false, the Puppet type 'service' will not be created
#   Can be usefull if the service is managed by a cluster manager
#
# [*service_name*]
#   Default: On Debian 'knot'. Name of the system service to manage
#
# [*service_restart*]
#   Default: '/usr/sbin/knotc reload'. Command to reload Knot
#
# [*service_status*]
#   Default: '/usr/sbin/knotc rstatus'. Command to check the status of Knot
#
# [*service_user*]
#   Default: On Debian 'knot'. User under which the knot daemon runs
#
# [*default_storage*]
#   Default: '/var/lib/knot'. Full path to the 'storage' dir
#
# [*main_config_file*]
#   Default: '/etc/knot/knot.conf'. Full path to the main configuration file
#
# [*manage_zones*]
#  Default: true. Set false if you want to manage only package and service.
#
# [*zone_defaults*]
#   Default: {}. Hash which contains default parameters which are added to every zone
#   definition under the 'zones' statement. Can be used f.e. to set a default template.
#   See https://www.knot-dns.cz/documentation/html/reference.html#zones-statement
#
# [*zones_config_file*]
#   Default: '/etc/knot/zones.conf'. Full path to the zones configuration file
#
# [*zones_config_template*]
#   Default: 'knot/zones.conf.erb'. Reference to zone.conf erb template
#
# [*acls*]
#   Default: {}
#   Acl section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#acl-section
#
# [*control*]
#   Default: {}
#   Control section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#control-section
#
# [*keys*]
#   Default: {}
#   Keys section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#key-section
#
# [*log*]
#   Default:
#     $log = {
#       syslog => {
#         any  => 'info'
#       }
#     }
#   Logging section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#logging-section
#
# [*modules*]
#   Default: {}
#   Modules section. See https://www.knot-dns.cz/docs/2.0/html/reference.html -> module-X
#   Key: module name without "mod-", Values: Hash of module parameters.
#
# [*remotes*]
#   Default: {}
#   Remotes section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#remote-section
#
# [*server*]
#   Default:
#     $server = {
#       listen => [
#         '0.0.0.0@53',
#         '::@53',
#       ]
#     }
#   Server section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#server-section
#
# [*templates*]
#   Default: {}
#   Template section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#template-section
#
# [*zones*]
#   Default: {}. Hash of zones. They will be added to the $zones_config_file file.
#   See https://www.knot-dns.cz/docs/2.0/html/reference.html#zone-section
#   Example:
#   $zones = {
#     'myzone.net'      => '',
#     'myotherzone.com' => {
#       'xfr-out'    => 'server1',
#       'notify-out' => 'server1' },
#   }
#
# [*dnssec_enable*]
#   Default: true. When set to true, then the $dnssec_keydir gets created and KASP initialized
#
# [*dnssec_keydir*]
#   Default: '/var/lib/knot/kasp'. Full path to the 'dnssec-keydir'
#
# [*signing_policies*]
#   Default: {}
#   Creates signing policies. See https://www.knot-dns.cz/docs/2.0/html/man_keymgr.html#policy-commands
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
  validate_hash($zone_defaults)
  validate_absolute_path($zones_config_file)

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
