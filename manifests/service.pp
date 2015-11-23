# == Class knot::service
#
# This class is meant to be called from knot.
# It ensure the service is running.
#
class knot::service {

  if $::knot::service_manage {
    # check config before managing service
    exec { 'check_knot_configuration':
      command     => "/usr/sbin/knotc -c ${::knot::main_config_file} checkconf",
      refreshonly => true,
    } ->
    service { $::knot::service_name:
      ensure     => $::knot::service_ensure,
      enable     => $::knot::service_enable,
      restart    => $::knot::service_restart,
      status     => $::knot::service_status,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
