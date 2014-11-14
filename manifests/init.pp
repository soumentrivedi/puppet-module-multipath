#
# == Class: multipath
#
# == Description:
#    Manage dm multipath on RHEL systems.
#
# == Params:
#
#    [*enable*]
#      Should the service be started at boot
#      Default: true
#
#    [*ensure*]
#      Should the service be running
#      Default: true
#
#    [*installed*]
#      Should the device-mapper-multipath be installed
#      Default: true
#
#    [*udev_dir*]
#      The directory where udev device nodes are created. The default value is /dev.
#      Default: /dev
#
#    [*polling_interval*]
#      Specifies the interval between two path checks in seconds.
#      For properly functioning paths, the interval between checks will gradually
#      increase to (4 * polling_interval). The default value is 5.
#      Default: 5
#
#    [*path_selector*]
#      Specifies the default algorithm to use in determining what path to use for the next I/O
#      operation. Possible values include:
#      round-robin 0, queue-length 0, service-time 0
#      Default: round-robin 0
#
#    [*path_grouping_policy*]
#      Specifies the default path grouping policy to apply to unspecified multipaths.
#      Possible values include:
#        failover, multibus, group_by_serial, group_by_prio, group_by_node_name
#      Default: failover
#
#    [*prio*]
#      Specifies the default function to call to obtain a path priority value.
#      Default: const
#
#    [*path_checker*]
#      Specifies the default method used to determine the state of the paths
#      Default: tur (Test Unit Ready)
#
#    [*rr_min_io*]
#      Specifies the number of I/O requests to route to a path before switching
#      to the next path in the current path group
#      Default: 1000
#
#    [*rr_weight*]
#      If set to priorities, then instead of sending rr_min_io requests to a
#      path before calling path_selector to choose the next path, the number
#      of requests to send is determined by rr_min_io times the path's priority,
#      as determined by the prio function. If set to uniform, all path weights are equal.
#      Default: uniform.
#
#    [*failback*]
#      Manage path group failback
#      Default: manual
#
#    [*no_path_retry*]
#      A numeric value for this attribute specifies the number of times the system should
#      attempt to use a failed path before disabling queueing.
#      Default: fail
#
#    [*user_friendly_names*]
#      If this is set to yes the multipath -ll command will give mpathX names
#      to LUNs insted of there numbers.
#      Default: yes
#
#    [*find_multipaths*]
#      Should we search for the multipaths?
#      (This will avoid blacklisting of local devices manualy)
#      Default: yes
#
class multipath (
  $enable               = true,
  $ensure               = true,
  $installed            = true,
  $polling_interval     = "30",
  $path_grouping_policy = "group_by_prio",
  $path_checker         = "tur",
  $rr_min_io            = "100",
  $failback             = "immediate",
  $no_path_retry        = "queue",
  $user_friendly_names  = 'yes',
  $find_multipaths      = 'no') {
  if ($is_virtual == 'false') and ($kernel == 'Linux') {
    package { "redhat-lsb": ensure => "installed" }
    validate_bool($enable)
    validate_bool($ensure)
    validate_bool($installed)

    # validate_re($udev_dir, '^\/')
    validate_re($path_grouping_policy, '^failover$|^multibus$|^group_by_serial$|^group_by_prio$|^group_by_node_name$')
    # validate_re($prio, '^const$|^emc$|^alua$|^tpg_pref$|^ontap$|^rdac$|^hp_sw$|^hds$')
    validate_re($path_checker, '^tur$|^readsector0$|^emc_clariion$|^hp_sw$|^rdac$|^directio$')
    validate_re($failback, '^manual$|^immediate$|^followover$')
    validate_re($no_path_retry, '^fail$|^queue$')
    validate_re($user_friendly_names, '^yes$|^no$')
    validate_re($find_multipaths, '^yes$|^no$')

    $ensure_real = $ensure ? {
      true  => 'running',
      false => 'stopped',
    }

    $installed_real = $installed ? {
      true  => 'present',
      false => 'absent',
    }

    $package_name = $lsbmajdistrelease ? {
      default => "device-mapper-multipath",
    }

    $mpath_config_file = $lsbmajdistrelease ? {
      default => "/etc/multipath.conf",
    }

    $mpath_template = $lsbmajdistrelease ? {
      default => template("${module_name}/multipath.conf.erb"),
    }

    $service_name = $lsbmajdistrelease ? {
      default => "multipathd",
    }

    package { $package_name: ensure => $installed_real, }

    file { $mpath_config_file:
      ensure  => $installed ? {
        true  => present,
        false => absent,
      },
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $mpath_template,
    }

    service { $service_name:
      ensure     => $ensure_real,
      enable     => $enable,
      hasstatus  => true,
      hasrestart => true,
    }

    Package['redhat-lsb'] ->
    Package[$package_name] ->
    File[$mpath_config_file] ~>
    Service[$service_name]
  }

} # End Class
