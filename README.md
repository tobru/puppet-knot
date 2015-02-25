#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with knot](#setup)
    * [What knot affects](#what-knot-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with knot](#beginning-with-knot)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module manages the [Knot DNS](https://www.knot-dns.cz/) server.

[![Build Status](https://travis-ci.org/tobru/puppet-knot.svg?branch=master)](https://travis-ci.org/tobru/puppet-knot)
[![tobru-knot](https://img.shields.io/puppetforge/v/tobru/knot.svg)](https://forge.puppetlabs.com/tobru/knot)

## Module Description

Knot DNS server is a "High-performance authoritative-only DNS server". This Puppet module
manages the configuration file `/etc/knot/knot.conf` and includes a separate configuration
file for the zones under `/etc/knot/zones.conf`.
Not every configuration parameter is directly exposed, instead it uses a "key/value" approach
in hashes, so that if there will be more/changed/other parameters in the future the module
will just work without any changes.
It also manages the installation of the package and starting/restarting the system service.

## Setup

### What knot affects

* Package `knot` installation. If `manage_package_repo` is true, it also adds the 
  [official apt repository](https://www.knot-dns.cz/documentation/html/installation.html#installing-knot-dns-packages-on-debian) by using the [puppetlabs/apt](https://forge.puppetlabs.com/puppetlabs/apt) module
* Service `knot` starting and restarting on configuration change
* Writing of configuration files:
  * `/etc/knot/knot.conf.puppet`
  * `/etc/knot/zones.conf.puppet`
* Creation of the folders and managing of the user and group rights
  on $zone_storage and $dnssec_keydir

### Beginning with knot

A simple `include knot` installs Knot DNS from the default package source and creates a configuration
file with sane defaults. When starting Knot DNS it complains `warning: no zones loaded`, this tells
us that it would make sense to add some zones.

Adding zones is as simple as follows:
```
class { 'knot':
  zones => { 'myzone.net'      => '',
             'myotherzone.com' => {
               'xfr-out'    => 'server1',
               'notify-out' => 'server1' },
           },
}
```

Zones will be added to `/etc/knot/zones.conf` with `file "mydomain.tld.zone";`.
This means that Knot DNS expects to find a standard zone file ([Wikipedia](http://en.wikipedia.org/wiki/Zone_file#File_format))
under `/var/lib/knot` (`storage` configuration directive under the `zones` section).

*Note*: The paramter `zones` is a [hash](https://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes)

## Usage

All parameter defaults are defined in `params.pp`. To pass a parameter to
the module, they need to be passed to the main class.
Here is a usage example for some parameters which most likely will be 
changed by the module user:

```
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
  keys                => { 'key0.server0' => {
                             'algorithm' => 'hmac-md5',
                             'key'       => 'Wg==' }
  },
  zones               => $zones,
}
```

*Hint*: As you can see, most parameters are hashes which make them look weird
and unreadable. That's a reason why using Hiera is recommended.

### Usage with Hiera

This module is fully compatible with Hiera. Here is an example on how
to pass parameters to the module:

```
knot::manage_package_repo: true
knot::package_distcodename: 'wheezy'
knot::dnssec_enable: false

knot::system:
  version: 'off'
knot::groups:
  admins: 'server0'
knot::log:
  syslog:
    any: 'warning'
  stderr:
    any: 'error, warning'
    server: 'info'
knot::keys:
  key0.server0:
    algorithm: 'hmac-md5'
    key: 'Wg=='
knot::remotes:
  server0:
    address: '127.0.0.1'
    port: '53531'
    key: 'key0.server0'
    via: 'all_ipv4'
  server1:
    address: '127.0.0.1@53001'

knot::zone_defaults:
  xfr-out: 'server0'
  notify-out: 'server0'
knot::zones:
  myzone.net:
  myotherzone.com:
    xfr-out: 'server1'
```

### Managing zones (and defaults for all zones)

Zones are passed to the main class in the `zones` hash. The configuration get's
written to `/etc/knot/zones.conf`.
To pass default values to all zones, the hash `zone_defaults` exists. Everything
in this hash is applied to all zones. If a parameter needs to be overwritten for
a single zone, just add this parameter to the zone, the zone parameters wins.

## Reference

All parameters are documented inline. Have a look at `init.pp`

## Testing

The module has some small [smoke tests](https://docs.puppetlabs.com/guides/tests_smoke.html) available under the
`tests/` subdirectory. To execute them invoke Puppet using the following simple command
in the modules root path: `puppet apply --modulepath .. --noop tests/init.pp`

There are also rspec-puppet tests available. To run them you first need to install all
needed GEMs by running bundler. Then a rake task executes the Rspec tests: `bundle exec rake spec`.

## Limitations

At this time this module is only tested under Ubuntu 14.04, but it should also
work on any other Linux distribution.
However package repo management (`$manage_package_repo`) is only supported on
Debian based OS families.

## Development

1. Fork it ( https://github.com/tobru/puppet-knot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.
