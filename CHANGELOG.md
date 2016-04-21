# CHANGELOG

## [2.1.1] - 2016-04-21
### Added
* New parameter for defining the place of the zones.conf erb template: `$zones_config_template`

### Fixed
* Various documentation updates and fixes
* Removed old parameters
* Replaced deprected `checkconf` by `conf-check`

## [2.1.0] - 2015-12-30
### Added
* New parameter for managing the server user: `$manage_user`

## [2.0.2] - 2015-12-29
### Fixed
* Typo in variable - preventing module to work under Puppet 4

## [2.0.1] - 2015-12-29
### Fixed
* Typo in variable - preventing module to work under Puppet 4

## [2.0.0] - 2015-12-29
### Added
* Support for Knot 2.x

This is a complete rewrite and does not support Knot 1.x anymore!

## [1.0.1] - 2015-02-22
### Added
* Preparations to support other OS families than only Debian
* Better metadata.json for Puppet forge
* More spec tests and travis integration

### Fixed
* Some code style issues against Puppet lint
* Correct handling of `zone_options` parameter

## [1.0.0] - 2015-02-20
### Added
* Initial release
