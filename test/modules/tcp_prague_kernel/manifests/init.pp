
class tcp_prague_kernel (
	String $install_path = '/home/vagrant',
	String $user = 'vagrant',
) {
	$kernel_repo = "https://github.com/L4STeam/tcp-prague.git"
	$kernel_cwd = 

	exec { 'kernel-download':
    require => Class['common'],
    creates => $kernel_cwd,
    command => "git clone  ${kernel_repo} ${kernel_cwd}"
  }
	exec { 'load-config':
		require => Exec['kernel-download'],
		creates => "${kernel_cwd}/.config",
		command => "cp /tmp/config-vm-tcpprague ${kernel_cwd}/.config"
	}
}

