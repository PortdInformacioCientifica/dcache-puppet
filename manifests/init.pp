# see README.markdown , ( but it will not help so much)

class dcache (
  $dcacheuser            = 'dcache',
  $dcachegroup           = 'dcache',
  $package_ensure        = 'present',
  $dcache_etc_dir        = '/etc/dcache',
  $bin_path              = '/bin',
  $package_name          = 'dcache',
  $conf                  = 'nodef',
  $admin_ssh_keys        = 'nodef',
  $layout                = 'nodef',
  $pools_setup           = 'nodef',
  $poolmanager_conf      = 'nodef',
  $gplazma_conf          = 'nodef',
  $ssh_authorized_keys   = 'nodef',
  # Cells
  $service_admin            = 'nodef',
  $service_gplazma          = 'nodef',
  $service_pinmanager       = 'nodef',
  $service_poolmanager      = 'nodef',
  $service_spacemanager     = 'nodef',
  $service_pnfsmanager      = 'nodef',
  $service_nfs              = 'nodef',
  # Directories
  $authorized_keys2      = "${dcache_etc_dir}/admin/authorized_keys2",
  $dcache_layout         = "${dcache_etc_dir}/layouts/${hostname}.conf",
  $gplazma_conf_path     = "${dcache_etc_dir}/gplazma.conf",
  $poolmanager_conf_path = '/var/lib/dcache/config/poolmanager.conf',
  $lock_version          = false,
  $service_ensure        = 'running'
  ) {

  if $::os[family] != 'RedHat' {
    fail("This module does NOT TESTED on ${::os[family]} ")
  }

  anchor { 'dcache::start': }

  class { 'dcache::install': require => Anchor['dcache::start'], }

  class { 'dcache::config':
    conf    => $conf,
    require => Class['dcache::install'],
  }

  class { 'dcache::layout':
    layout_hash => $layout,
    p_setup     => $pools_setup,
    require     => Class['dcache::config'],
  }

  class { 'dcache::service':
    require => Class['dcache::layout'],
  } ->
  anchor { 'dcache::end': }

  # Optional configurations
  if $::dcache::service_admin != 'nodef' {
    if $::dcache::ssh_authorized_keys != 'nodef' {
      class { 'dcache::authorized_keys2':; }
    } else {
      warning('dcache::ssh_authorized_keys is not defined, needed by the dcache "admin" service')
    }
  }

}
