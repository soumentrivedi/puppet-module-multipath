Puppet module multipath
=======================

The module manages DM-Multipathing on redhat family systems.

##Usage:

  ```puppet
  class {'multipath':
   user_friendly_names  => "yes",
   path_grouping_policy => "failover", 
  }
  ```
  To remove multipath:
  ```puppet
  class {'multipath':
    installed => false,
  }
  ```

##Other class parameters
  * enable: true or false, default: true
  * ensure: true or false, default: true
  * installed: true or false, default: true
  * udev_dir: /dev
  * polling_interval: 5
  * path_selector: round-robin 0
  * path_grouping_policy: failover|multibus|group_by_serial|group_by_prio|group_by_node_name, 
    default: multibus
  * getuid_callout
  * prio: const, emc, alua, tpg_pref, ontap, rdac, hp_sw, hds, default: const
  * path_checker: tur, readsector0, emc_clariion, hp_sw, rdac, directio, default: directio
  * rr_min_io: 1000
  * rr_weight: uniform
  * failback: manual, immediate, folowover, default: manual
  * no_path_retry: fail, queue, defaul: fail
  * user_friendly_names: yes or no, default: yes
  * find_multipaths: yes or no, default: yes


# License
Licensed under the Apache License, Version 2.0
