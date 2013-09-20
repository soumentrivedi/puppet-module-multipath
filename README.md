Puppet module multipath
=======================

The module manages DM-Multipathing on redhat family systems.

##Usage:

  ```puppet
  class {'multipath':
   user_friendly_names => 'yes',
  }
  ```
##Other class parameters
  * enable: true or false, default: true
  * ensure: true or false, default: true
  * user_friendly_names: yes or no, default: yes
  * path_grouping_policy: failover|multibus|group_by_serial|group_by_prio|group_by_node_name, default: multibus
  * find_multipaths: yes or no, default: yes

# License
Licensed under the Apache License, Version 2.0
