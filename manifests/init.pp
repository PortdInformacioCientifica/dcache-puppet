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
  $auto_configuration    = 'false',
  $service_admin         = 'false',
  $service_gplazma       = 'false',
  $service_pinmanager    = 'false',
  $service_poolmanager   = 'false',
  $service_spacemanager  = 'false',
  $service_pnfsmanager   = 'false',
  $service_nfs           = 'false',
  # Directories
  $path_authorized_keys2 = "$dcache::dcache_etc_dir/admin/authorized_keys2",
  $path_dcache_layout    = "$dcache::dcache_etc_dir/layouts/${hostname}.conf",
  $path_gplazma_conf     = "$dcache::dcache_etc_dir/gplazma.conf",
  $path_poolmanager_conf = '/var/lib/dcache/config/poolmanager.conf',
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

  # dCache service configuration
  if $::dcache::service_admin == 'true' {
    class { "dcache::services::admin":; }
  }

}
