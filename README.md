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

### Beginning with knot

A simple `include knot` installs Knot DNS from the default package source and creates a configuration
file with sane defaults. When starting Knot DNS it complains `warning: no zones loaded`, this tells
us that it would make sense to add some zones.

Adding a zone is as simple as follows:
```
class { 'knot':
  zones => { 'mydomain.tld' => '' }
}
```

Zones will be added to `/etc/knot/zones.conf` with `file "mydomain.tld.zone";`.
This means that Knot DNS expects to find a standard zone file ([Wikipedia](http://en.wikipedia.org/wiki/Zone_file#File_format))
under `/var/lib/knot` (`storage` configuration directive under the `zones` section).

*Note*: `zones` is a [hash](https://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes)

## Usage

All parameter defaults are defined in `params.pp`. To pass a parameter to
the module, they need to be passed to the main class.
Here is a usage example for some parameters which most likely will be 
changed:

```
```

### Usage with hiera

This module is fully compatible with hiera. Here is an example on how
to pass the same parameters to hiera like to example above:

```
```


## Reference


## Limitations

At this time it is only tested under Ubuntu 14.04, but it should also work on Debian or any other
.deb based distribution.

## Development

1. Fork it ( https://github.com/tobru/puppet-knot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.
