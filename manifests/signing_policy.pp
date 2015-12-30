#
define knot::signing_policy (
  $data,
  $dnssec_keydir,
  $user,
  $group,
) {

  $_params_hash = $data[$name]
  $_params = inline_template('<%- @_params_hash.each do |k,v| -%><%= k -%> <%= v -%> <% end -%>')

  exec { "create_signing_policy_${name}":
    command => "/usr/sbin/keymgr policy add ${name} ${_params}",
    creates => "${dnssec_keydir}/policy_${name}.json",
    cwd     => $dnssec_keydir,
    user    => $user,
    group   => $group,
    require => Package[$::knot::package_name],
  }

}
