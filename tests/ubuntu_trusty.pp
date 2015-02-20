# This is an example on how to invoke the module using some
# parameters on Ubuntu 14.04 (see also README.md)
#
$zones = {
  'myzone.net'      => '',
  'myotherzone.com' => {
    'xfr-out'    => 'server1',
    'notify-out' => 'server1' },
}

class { 'knot':
  manage_package_repo => false,
  system              => { 'version' => 'off' },
  groups              => { 'admins'  => 'server0' },
  log                 => { 'syslog'  => { 'any'    => 'warning' },
                           'stderr'  => { 'any'    => 'error',
                                          'server' => 'info'  }
  },
  keys                => { 'key0.server0' => {
                             'algorithm' => 'hmac-md5',
                             'key'       => 'Wg==' }
  },
  remotes             => { 'server0' => {
                             'address' => '127.0.0.1',
                             'port'    => '53531',
                             'key'     => 'key0.server0',
                             'via'     => 'all_ipv4' },
                           'server1' => {
                             'address' => '127.0.0.1@53001' },
  },
  zone_defaults       => { 'xfr-out'    => 'server0',
                           'notify-out' => 'server0' },
  zones               => $zones,
}
