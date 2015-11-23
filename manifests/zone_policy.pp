#
define knot::zone_policy (
  $dnssec_keydir,
  $group,
  $templates,
  $user,
  $zones,
) {

  $_zone_config = $zones[$name]

  if $_zone_config['_signing_policy'] {
    $_policy = $_zone_config['_signing_policy']
  } elsif $_zone_config['template'] {
    $_template = $_zone_config['template']
    if $templates[$_template]['_signing_policy'] {
      $_policy = $templates[$_template]['_signing_policy']
    }
  }

  if $_policy {
    exec { "create_zone_signing_policy_${name}":
      command  => "/usr/sbin/keymgr zone add ${name} policy ${_policy}",
      creates => "${dnssec_keydir}/zone_${name}.json",
      cwd      => $dnssec_keydir,
      user     => $user,
      group    => $group,
      require  => ::Knot::Signing_policy[$_policy],
    }
  }

}
