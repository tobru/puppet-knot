# == Class knot::service
#
# This class is meant to be called from knot.
# It ensure the service is running.
#
class knot::service {

  $service_manage = $knot::service_manage
  $service_name   = $knot::service_name
  $service_ensure = $knot::service_ensure
  $service_enable = $knot::service_enable

  if $service_manage {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
