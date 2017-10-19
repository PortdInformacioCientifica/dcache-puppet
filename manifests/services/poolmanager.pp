# dcache::services:poolmanager
#  |- Add here configurations for the 'poolmanager' service

class dcache::services::poolmanager (
  $path_poolmanager_conf = $::dcache::path_poolmanager_conf,
  $poolmanager_conf_type = $::dcache::poolmanager_conf_type,
  $poolmanager_conf      = $::dcache::poolmanager_conf,
  $path_srm22            = $::dcache::path_srm22,
  $srm22_filename        = $::dcache::$srm22_filename
) {
    # Private class generates poolmanager.conf
  if ($poolmanager_conf != 'nodef') {
    if ($poolmanager_conf_type != 'nodef' and $poolmanager_conf_type != 'srm22') {
      crit("'$poolmanager_conf_type' with incorrect value. Should be 'nodef' or 'srm22'")
    }

    if ($poolmanager_conf_type == 'nodef') {
      #  dump poolmamager as multiline string : e.g.
      #  poolmanager_cfg: |
      #    cm set debug off
      #    rc set max threads 2147483647
      #    pm set -sameHostRetry=notchecked -p2p-oncost=yes -stage-oncost=no
      #
      if is_string($poolmanager_conf) {
        $content = $poolmanager_conf
      } else {
        #   gererate poolmanager.conf from hash : e.g.
        #   poolmanager_cfg:
        #    cm:
        #       - 'set debug off'
        #     rc:
        #       - 'set max threads 2147483647'
        #     pm:
        #        default:
        #         type: 'wass'
        #         options:
        #           sameHostRetry: 'notchecked'
        #     psu:
        #       set:
        #         - 'regex off'
        #       unitgroups:
        $content = template('dcache/poolmanager.conf.erb')
      }
  
      file { "${path_poolmanager_conf}.puppet":
        owner   => $::dcache::dcacheuser,
        group   => $::dcache::dcachegroup,
        mode    => '0644',
        content => $content,
        require => Exec["save_custom_pm"],
        notify  => Exec['reload_pm'],
      }
  
      exec { "save_custom_pm":
        command => "/bin/cp -f ${path_poolmanager_conf} ${path_poolmanager_conf}.puppet;/bin/cp -f ${path_poolmanager_conf} ${path_poolmanager_conf}.puppet.save  ",
        onlyif  => "/usr/bin/test ${path_poolmanager_conf} -nt ${path_poolmanager_conf}.puppet",
        path    => $::path
      }
  
      exec { 'reload_pm':
        command     => "cp -p  ${path_poolmanager_conf}.puppet ${path_poolmanager_conf}",
        refreshonly => true,
        #      onlyif      => "dcache status",
        path        => $::path,
        logoutput   => false,
      }
    }
    if ($poolmanager_conf_type == 'srm22') {
      notice("This is a srm22 config")
      file {
        "$path_srm22":
          ensure => 'directory',
          mode   => '0755',
          owner  => 'root',
          group  => 'root'
        "$path_srm22/historic":
          ensure => 'directory',
          mode   => '0755',
          owner  => 'root',
          group  => 'root'
        "$path_srm22/LinkGroupAuthorization.xsl":
          ensure => 'present',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
          source => 'puppet:///modules/dcache/common/root/srm22/LinkGroupAuthorization.xsl'
        "$path_srm22/poolmanagerconfig.xsl":,
          ensure => 'present',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
          source => 'puppet:///modules/dcache/common/root/srm22/poolmanagerconfig.xsl'
        "$path_srm22/$srm22_filename":
          ensure => 'present',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
          source => "puppet:///modules/dcache/common/root/srm22/srm22.xml"
      }
    }
  } 
}
