# == Class: knot
#
# Main class for the knot module. Every parameter needs to be passed to
# this class.
#
# === Parameters
#
# [*package_ensure*]
#   Default: installed. See Puppet type 'package' documentation
#
# [*package_name*]
#   Default: On Debian 'knot'. Package name to install knot
#
# [*package_distcodename*]
#   Default: $::lsbdistcodename. Used in conjunction with *manage_package_repo*.
#   Can be used to change the codename of the distro for the package repository
#
# [*manage_package_repo*]
#   Default: false. If set to true, make sure the puppetlabs/apt module is available
#   as it adds the knot-dns.cz repo to the APT sources
#
# [*service_name*]
#   Default: On Debian 'knot'. Name of the system service to manage
#
# [*service_enable*]
#   Default: true. See Puppet type 'service' documentation
#
# [*service_ensure*]
#   Default: running. See Puppet type 'service' documentation
#
# [*service_manage*]
#   Default: true. If set to false, the Puppet type 'service' will not be created
#   Can be usefull if the service is managed by a cluster manager
#
# [*service_user*]
#   Default: On Debian 'knot'. User under which the knot daemon runs
#
# [*service_group*]
#   Default: On Debian 'knot'. Group under which the knot daemon runs
#
# [*main_config_file*]
#   Default: '/etc/knot/knot.conf'. Full path to the main configuration file
#
# [*zones_config_file*]
#   Default: '/etc/knot/zones.conf'. Full path to the zones configuration file
#
# [*system*]
#   Default:
#     $system = {
#        identity => 'on',
#        version  => 'on',
#     }
#   System statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#system-statement
#
# [*log*]
#   Default:
#     $log = {
#       syslog => {
#         any  => 'info'
#       },
#       stderr => {
#         any  => 'warning'
#       }
#     }
#   Log statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#log-statement
#
# [*interfaces*]
#   Default:
#     $interfaces = {
#       all_ipv4  => {
#         address => '0.0.0.0',
#         port    => 53,
#       },
#       all_ipv6  => {
#         address => '[::]',
#         port    => 53,
#       }
#     }
#   Interfaces statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#interfaces-statement
#
# [*control*]
#   Default:
#     $control = {
#       listen-on => 'knot.sock'
#     }
#   Control statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#control-statement
#
# [*keys*]
#   Default: undef
#   Keys statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#keys-statement
#
# [*remotes*]
#   Default: undef
#   Remotes statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#remotes-statement
#
# [*groups*]
#   Default: undef
#   Groups statement hash. See https://www.knot-dns.cz/documentation/html/reference.html#groups-statement
#
# [*dnssec_enable*]
#   Default: false. When set to enable, then the $dnssec_keydir gets created and "dnssec-enable"
#   set to 'on' under the 'zones' statement.
#
# [*dnssec_keydir*]
#   Default: '/etc/knot/dnssec_keys.d'. Full path to the 'dnssec-keydir'
#
# [*zone_storage*]
#   Default: '/var/lib/knot'. Full path to the 'storage' dir which holds the zonefiles
#
# [*zone_defaults*]
#   Default: undef. Hash which contains default parameters which are added to every zone
#   definition under the 'zones' statement.
#   See https://www.knot-dns.cz/documentation/html/reference.html#zones-statement
#
# [*zone_options*]
#   Default: undef. Hash with zone options for the 'zones' statement.
#   See https://www.knot-dns.cz/documentation/html/reference.html#zones-statement
#
# [*zones*]
#   Default: {}. Hash of zones. They will be added to the $zones_config_file file and the
#   'file' option automatically set to "<zonename>.zone", which is relative to 'storage'.
#   See https://www.knot-dns.cz/documentation/html/reference.html#zones-statement
#   Example:
#   $zones = {
#     'myzone.net'      => '',
#     'myotherzone.com' => {
#       'xfr-out'    => 'server1',
#       'notify-out' => 'server1' },
#   }
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
  validate_absolute_path($main_config_file)
  validate_absolute_path($zones_config_file)
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
