# == Class knot::service
#
# This class is meant to be called from knot.
# It ensure the service is running.
#
class knot::service inherits knot {

  if $service_manage {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
