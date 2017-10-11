# dcache::services:admin
#  |- Add here configurations for the 'admin' service

class dcache::services::admin ($ssh_tmp_dir = '/tmp',) {
  # Generate authorized_keys2 file
  # Required:
  #   |- $dcache::dcacheuser
  #   |- $dcache::path_authorized_keys2
  #   |- $dcache::ssh_authorized_keys

  $authorized_keys2_defaults = {
    ensure  => 'present',
    type    => 'ssh-rsa',
    user    => $dcache::dcacheuser,
    target  => $dcache::path_authorized_keys2,
    options => 'from="*"',
  }
  
  if $::dcache::ssh_authorized_keys != 'nodef' {
    $authorized_keys2 = hiera_hash('dcache::ssh_authorized_keys', {})
    create_resources('ssh_authorized_key', $authorized_keys2, $authorized_keys2_defaults )
  } else {
    warning('dcache::ssh_authorized_keys is not defined, may be needed by the dcache "admin" service')
  }

  ## START: OLD CODE
  #

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
  #   path => "${::dcache::path_authorized_keys2}",
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
  
  #
  ## END: OLD CODE

}
