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

**Info: Module version 2.x is only compatible with Knot 2.x. If you're still on Knot 1.x, please
use the module version 1.x.**

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
  [official apt repository](https://www.knot-dns.cz/docs/2.0/html/installation.html#os-specific-installation) by using the [puppetlabs/apt](https://forge.puppetlabs.com/puppetlabs/apt) module
* Service `knot` starting and restarting on configuration change
* Writing of configuration files:
  * `/etc/knot/knot.conf.puppet`
  * `/etc/knot/zones.conf.puppet`
* Creation of the folders and managing of the user and group rights
  on `$default_storage` and `$dnssec_keydir`
* Creation of Signing Policies

### Beginning with knot

A simple `include knot` installs Knot DNS from the default package source and creates a configuration
file with sane defaults. When starting Knot DNS it complains `warning: no zones loaded`, this tells
us that it would make sense to add some zones.
Please note: Your distro will most likely not yet include Knot 2.x. So you should set at least
the parameter `manage_package_repo` to true.

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

Zones will be added to `/etc/knot/zones.conf`.

*Note*: The paramter `zones` is a [hash](https://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes)

## Usage

All parameter defaults are defined in `params.pp` and `init.pp`. To pass a parameter to
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
  manage_package_repo => true,
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

knot::zones:
  myzone.ch:
    template: dnssec
    _signing_policy: default_rsa
  myotherzone.ch: {}
knot::server:
  identity: 'noidentityhere'
knot::acls:
  myacl1:
    action: transfer
knot::control:
  acl: myacl1
knot::remotes:
  myremote1:
    address: 127.0.0.1
    key: key1
knot::templates:
  dnssec:
    dnssec-signing: on
    storage: /var/lib/knot
    zonefile-sync: -1
    kasp-db: /var/lib/knot/kasp
    file: /var/lib/knot/zones/%s.zone
    _signing_policy: default_rsa
  default:
    storage: /var/lib/knot
    file: /var/lib/knot/zones/%s.zone
knot::log:
  stderr:
    any: debug
knot::keys:
  key1:
    algorithm: hmac-md5
    secret: c0570d4931593d46333c9ddf15894a8550e131f4
  key2:
    algorithm: hmac-sha1
    secret: c0570d4931593d46333c9ddf15894a8550e131f4
knot::signing_policies:
  default_rsa:
    algorithm: RSASHA256
    zsk-size: 1024
    ksk-size: 2048
knot::modules:
  dnstap:
    sink: unix://var/run/sink
  synth-record:
    type: forward
    prefix: bla
    origin: blubb.ch
```

*Note*: This is not a fully functional configuration, it's just here for an example
on how to use Hiera.

### Managing zones (and defaults for all zones)

Zones are passed to the main class in the `zones` hash. The configuration get's
written to `/etc/knot/zones.conf`.
To pass default values to all zones, the hash `zone_defaults` exists. Everything
in this hash is applied to all zones. If a parameter needs to be overwritten for
a single zone, just add this parameter to the zone, the zone parameters wins.
Since Knot 2.x gained the template functionality, this feature will most likely
only be used for setting a default template for all zones.

### Automatic DNSSEC signing

For an overview on how automatic DNSSEC signing works in Knot, see [official docs](https://www.knot-dns.cz/docs/2.0/html/configuration.html#automatic-dnssec-signing).
The Puppet module prepares the `DNSSEC KASP database` and is able to create signing
policies. Just pass a hash of policies to the parameter `signing_policies`.
Setting the special (Puppet module only) parameter `_signing_policy` to a name
of a signing policy under a zone or template will configure this policy to a zone.

Overview of file locations with the following template configured:
```
knot::templates:
  dnssec:
    dnssec-signing: on
    storage: /var/lib/knot
    zonefile-sync: -1
    kasp-db: /var/lib/knot/kasp
    file: /var/lib/knot/zones/%s.zone
    _signing_policy: default_rsa
```

* Zonefiles: `/var/lib/knot/zones/%s.zone`
* KASP DB: `/var/lib/knot/kasp`
* Zone keys: `/var/lib/knot/kasp/keys`
* Timers: `/var/lib/knot/timers`
* Signed zones: Only in memory (`zonefile-sync` is -1) and under `/var/lib/knot/<zone>.db`

Using this configuration the directory `/var/lib/knot/zones` can be savely managed
with git.

## Reference

### Classes

#### Public Classes

* `knot`: Installs and configures Knot in your environment.

All configuration is passed to `init.pp`:

[*manage_package_repo*]
  Default: false. If set to true, make sure the puppetlabs/apt module is available
  as it adds the knot-dns.cz repo to the APT sources

[*package_ensure*]
  Default: installed. See Puppet type 'package' documentation

[*package_name*]
  Default: On Debian 'knot'. Package name to install knot

[*package_repo_key*]
  Default: Depends on $::lsbdistid, see params.pp.
  Only used when $manage_package_repo is true.
  Signing key of the packages

[*package_repo_key_src*]
  Default: Depends on $::lsbdistid, see params.pp.
  Only used when $manage_package_repo is true.
  Source of the package signing public key

[*package_repo_location*]
  Default: Depends on $::lsbdistid, see params.pp.
  Only used when $manage_package_repo is true.
  Location of the package repository

[*package_repo_repos*]
  Default: Depends on $::lsbdistid, see params.pp.
  Only used when $manage_package_repo is true.
  Repos used on the repository location

[*manage_user*]
  Default: true. Manages the Puppet user resource for the user $service_user

[*service_enable*]
  Default: true. See Puppet type 'service' documentation

[*service_ensure*]
  Default: running. See Puppet type 'service' documentation

[*service_group*]
  Default: On Debian 'knot'. Group under which the knot daemon runs

[*service_manage*]
  Default: true. If set to false, the Puppet type 'service' will not be created
  Can be usefull if the service is managed by a cluster manager

[*service_name*]
  Default: On Debian 'knot'. Name of the system service to manage

[*service_restart*]
  Default: '/usr/sbin/knotc reload'. Command to reload Knot

[*service_status*]
  Default: '/usr/sbin/knotc rstatus'. Command to check the status of Knot

[*service_user*]
  Default: On Debian 'knot'. User under which the knot daemon runs

[*default_storage*]
  Default: '/var/lib/knot'. Full path to the 'storage' dir

[*main_config_file*]
  Default: '/etc/knot/knot.conf'. Full path to the main configuration file

[*manage_zones*]
 Default: true. Set false if you want to manage only package and service.

[*zone_defaults*]
  Default: {}. Hash which contains default parameters which are added to every zone
  definition under the 'zones' statement. Can be used f.e. to set a default template.
  See https://www.knot-dns.cz/documentation/html/reference.html#zones-statement

[*zones_config_file*]
  Default: '/etc/knot/zones.conf'. Full path to the zones configuration file

[*zones_config_template*]
  Default: 'knot/zones.conf.erb'. Reference to zone.conf erb template

[*acls*]
  Default: {}.
  Acl section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#acl-section

[*control*]
  Default: {}.
  Control section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#control-section

[*keys*]
  Default: {}.
  Keys section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#key-section

[*log*]
  Default:
```
    $log = {
      syslog => {
        any  => 'info'
      }
    }
```
  Logging section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#logging-section

[*modules*]
  Default: {}.
  Modules section. See https://www.knot-dns.cz/docs/2.0/html/reference.html -> module-X
  Key: module name without "mod-", Values: Hash of module parameters.

[*remotes*]
  Default: {}.
  Remotes section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#remote-section

[*server*]
  Default:
```
    $server = {
      listen => [
        '0.0.0.0@53',
        '::@53',
      ]
    }
```
  Server section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#server-section

[*templates*]
  Default: {}.
  Template section. See https://www.knot-dns.cz/docs/2.0/html/reference.html#template-section

[*zones*]
  Default: {}. Hash of zones. They will be added to the $zones_config_file file.
  See https://www.knot-dns.cz/docs/2.0/html/reference.html#zone-section
  Example:
```
  $zones = {
    'myzone.net'      => '',
    'myotherzone.com' => {
      'xfr-out'    => 'server1',
      'notify-out' => 'server1' },
  }
```

[*dnssec_enable*]
  Default: true. When set to true, then the $dnssec_keydir gets created and KASP initialized

[*dnssec_keydir*]
  Default: '/var/lib/knot/kasp'. Full path to the 'dnssec-keydir'

[*signing_policies*]
  Default: {}.
  Creates signing policies. See https://www.knot-dns.cz/docs/2.0/html/man_keymgr.html#policy-commands

#### Private Classes

* `knot::install`: Manages the APT repo and installs Knot
* `knot::config`: Writes the Knot configuration files and prepares DNSSEC things
* `knot::service`: Manages the Knot system service

### Defined Types

* `knot::signing_policy`: Adds signing policy using `keymgr`
* `knot::zone_policy`: Adds zone policy using `keymgr`

## Testing

There are rspec-puppet tests available. To run them you first need to install all
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
