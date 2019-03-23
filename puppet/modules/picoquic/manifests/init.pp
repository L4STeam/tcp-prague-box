
class picoquic (
	String $install_path = '/home/vagrant',
	String $user = 'vagrant',
) {
	$picotls_cwd = "${install_path}/picotls"
	$picotls_repo = "https://github.com/h2o/picotls.git"
	$picoquic_cwd = "${install_path}/picoquic"
	$picoquic_repo = "https://github.com/private-octopus/picoquic.git"

	exec { 'picotls-download':
    require => Class['common'],
    creates => $picotls_cwd,
    command => "git clone  --recurse-submodules ${picotls_repo} ${picotls_cwd} &&\
                chown -R ${user}:${user} ${picotls_cwd}"
  }

	exec { 'picoquic-download':
    require => Class['common'],
    creates => $picoquic_cwd,
    command => "git clone  --recurse-submodules ${picoquic_repo} ${picoquic_cwd}"
  }

	exec { 'picotls':
		require => [ Class['common'], Exec['picotls-download'], Package['cmake'] ],
		cwd => $picotls_cwd,
		command => "cmake . && make",
	}

  exec { 'picoquic':
		require => [ Class['common'], Exec['picoquic-download'], Exec['picotls'], Package['cmake'] ],
		cwd => $picoquic_cwd,
		command => "cmake . && make",
	}
}
