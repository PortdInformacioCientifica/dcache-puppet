# dcache::services:gplazma
#  |- Add here configurations for the 'gplazma' service

class dcache::services:gplazma ($path_gplazma_conf = $::dcache::path_gplazma_conf, $gplazma_conf = $::dcache::gplazma_conf,) {
  if ($gplazma_conf != 'nodef') {
    file { "${path_gplazma_conf}.puppet":
      owner   => $::dcache::dcacheuser,
      group   => $::dcache::dcachegroup,
      mode    => '0644',
      content => join([inline_template('<%= @gplazma_conf.join("\n") %>'), "\n"], ''),
      require => Exec["save_custom_gplazma"],
    }

    exec { "save_custom_gplazma":
      command => "/bin/cp -f ${path_gplazma_conf} ${path_gplazma_conf}.puppet;/bin/cp -f ${path_gplazma_conf} ${path_gplazma_conf}.puppet.save",
      onlyif  => "/usr/bin/test ${path_gplazma_conf} -nt ${path_gplazma_conf}.puppet",
      path    => $::path
    }

  }
}
