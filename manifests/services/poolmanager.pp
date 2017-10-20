# dcache::services:poolmanager
#  |- Add here configurations for the 'poolmanager' service

class dcache::services::poolmanager (
  $poolmanager_conf = '/var/lib/dcache/config/poolmanager.conf',
  $poolmanager_type = 'nodef'
) {
    # Private class generates poolmanager.conf
  if ($poolmanager_conf != 'nodef') {
    if ($poolmanager_type != 'nodef' and $poolmanager_type != 'srm22') {
      crit("'$poolmanager_type' with incorrect value. Should be 'nodef' or 'srm22'")
    }

    if ($poolmanager_type == 'nodef') {
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
  
      file { "${poolmanager_conf}.puppet":
        owner   => $::dcache::dcacheuser,
        group   => $::dcache::dcachegroup,
        mode    => '0644',
        content => $content,
        require => Exec["save_custom_pm"],
        notify  => Exec['reload_pm'],
      }
  
      exec { "save_custom_pm":
        command => "/bin/cp -f ${poolmanager_conf} ${poolmanager_conf}.puppet;/bin/cp -f ${poolmanager_conf} ${poolmanager_conf}.puppet.save  ",
        onlyif  => "/usr/bin/test ${poolmanager_conf} -nt ${poolmanager_conf}.puppet",
        path    => $::path
      }
  
      exec { 'reload_pm':
        command     => "cp -p  ${poolmanager_conf}.puppet ${poolmanager_conf}",
        refreshonly => true,
        #      onlyif      => "dcache status",
        path        => $::path,
        logoutput   => false,
      }
    }
    if ($poolmanager_type == 'srm22') {
      notice("This is a srm22 config. Puppet code needs to be deployed.")
      # This module actually is managed outside the dCache puppet module
      # SRM22 is a XSL/XML based script to generate poolmamanger.conf and Linkgroups.conf
      # PIC is using SRM22 instead of generating poolmanager.conf
      # However poolmanager.conf.erb method was kept by default from Jülich puppet deployment as this is the best and most common way to generate the poolmanager.conf file
      # This part of the code allows to configure SRM22 inside the 'dcache-puppet' module
      # Please add here corresponding puppet code for deploying SRM22
    }
  } 
}
