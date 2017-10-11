# dcache::services:poolmanager
#  |- Add here configurations for the 'poolmanager' service

class dcache::services::poolmanager (
  $path_poolmanager_conf = $::dcache::path_poolmanager_conf,
  $poolmanager_conf      = $::dcache::poolmanager_conf,) {
    # Private class generates poolmanager.conf
  if ($poolmanager_conf != 'nodef') {
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
      #          sameHostRetry: 'notchecked'
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
}
