class dcache::services::admin ($ssh_tmp_dir = '/tmp',) {
  # exec { "generate _ssh_key":
  #   command => "ssh-keygen -f ${ssh_tmp_dir}/dc_key.rsa -t rsa -N ''",
  #   path    => $::path,
  #   creates => ["${ssh_tmp_dir}/dc_key.rsa", "${ssh_tmp_dir}/dc_key.rsa.pub"],
  # }

  # file { "${ssh_tmp_dir}/dc_ssh_config":
  #   content => "Port=22224\nUser=adminn\nIdentityFile=/tmp/dc_key.rsa\nUserKnownHostsFile=/dev/null\nStrictHostKeyChecking=no",
  #   require => Exec["generate _ssh_key"],
  # }
  # notice(generate('/bin/cat', "${ssh_tmp_dir}/dc_key.rsa.pub"),)

  # file_line { 'tmp_admin':
  #   path => "${::dcache::authorized_keys2}",
  #   line => generate('/bin/cat', "${ssh_tmp_dir}/dc_key.rsa.pub"),
  # }

  # exec { 'Validate dcache admin interface':
  #   command   => "echo 'Unable to connect to dcache admin interface' && false",
  #   unless    => "echo -e logoff | ssh -F ${ssh_tmp_dir}/dc_ssh_config localhost",
  #   cwd       => '/tmp',
  #   logoutput => 'on_failure',
  #   path      => $::path,
  #   timeout   => 20,
  #   require   => File["${ssh_tmp_dir}/dc_ssh_config"],
  # }

  $authorized_keys2_defaults = {
    ensure  => 'present',
    type    => 'ssh-rsa',
    user    => $dcache::dcacheuser,
    target  => $dcache::authorized_keys2,
    options => 'from="*"',
  }
  
  $authorized_keys2 = hiera_hash('dcache::ssh_authorized_keys', {})
  create_resources('ssh_authorized_key', $authorized_keys2, $authorized_keys2_defaults )


}
