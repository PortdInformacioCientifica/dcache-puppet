class dcache::authorized_keys2() {
      $authorized_keys2_defaults = {
        ensure  => 'present',
        type    => 'ssh-rsa',
        user    => $dcache::dcacheuser,
        group   => $dcache::dcachegroup,
        target  => $dcache::authorized_keys2,
        options => 'from="*"',
      }

      $authorized_keys2 = hiera_hash('dcache::authorized_keys2', {})
      create_resources('ssh_authorized_key', $authorized_keys2, $authorized_keys2_defaults )
}
