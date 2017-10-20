class dcache::layout ($l_file = $::dcache::path_dcache_layout, $layout_hash = 'nodef', $p_setup = 'nodef',) {

  if is_hash($layout_hash) {
    if deep_has_key($layout_hash, 'dCacheDomain') {
      class { 'dcache::services::poolmanager': }
    }

    if deep_has_key($layout_hash, 'gplazma') {
      class { 'dcache::services::gplazma': require => Class['dcache::install'], }
    }
  }

  if ($layout_hash != 'nodef') {
    file { "${l_file}.puppet":
      owner   => $dcache::dcacheuser,
      group   => $dcache::dcachegroup,
      mode    => '0644',
      content => template('dcache/layout.conf.erb'),
      notify  => Exec['dcache-refresh_layuot'],
    }

    if ($p_setup != 'nodef') {
      $pools = deep_merge($p_setup, collect_pools_paths($layout_hash['domains']))
    } else {
      $pools = collect_pools_paths($layout_hash['domains'])
    }
    create_resources(dcache::layout::pool, $pools)

  }

}
