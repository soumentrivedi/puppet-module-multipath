#
# == Class: multipath
#
# == Description:
#    Manage multipath on RHEL systems.
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
#    [*user_friendly_names*]
#      If this is set to yes the multipath -ll command will give mpathX names
#      to LUNs insted of there numbers.
#      Default: yes
#
#    [*path_grouping_policy*]
#      Which algorithm to use for multipathing
#      Default: multibus
#
#    [*find_multipaths*]
#      Should we search for the multipaths?
#      (This will avoid blacklisting of local devices manualy)
#      Default: yes
#
class multipath(
  $enable = true,
  $ensure = true,
  $user_friendly_names = 'yes',
  $path_grouping_policy = 'multibus',
  $find_multipaths = 'yes'
){
  if ($is_virtual == 'false') and ($kernel == 'Linux') {

    validate_bool($enable)
    validate_bool($ensure)
    validate_re($user_friendly_names, '^yes$|^no$')
    validate_re($path_grouping_policy, '^failover$|^multibus$|^group_by_serial$|^group_by_prio$|^group_by_node_name$')
    validate_re($find_multipaths, '^yes$|^no$')
      
    $ensure_real = $ensure ? {
      true  => 'running',
      false => 'stopped',
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
      
    package {$package_name:
      ensure => installed,
    }
     
    file {$mpath_config_file:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $mpath_template,
    }
      
    service {$service_name:
      ensure     => $ensure_real,
      enable     => $enable_real,
      hasstatus  => true,
      hasrestart => true,
    }
     
    Package[$package_name] -> File[$mpath_config_file] ~> Service[$service_name]
  }
}# End Class
