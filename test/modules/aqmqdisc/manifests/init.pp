
class aqmqdisc (
	String $version = 'master',
	String $user_path = '/home/vagrant',
) {
	$git_repo = "https://github.com/L4STeam/iproute2.git"
	$kernel_module_repo = "https://github.com/olgaalb/sch_dualpi2.git"
	$iproute2_cwd = "${user_path}/iproute2"
	$kernel_module_cwd = "${user_path}/sch_dualpi2"

	exec { 'iproute2-download':
		require => Exec['apt-update'],
		creates => $iproute2_cwd,
		command => "git clone ${git_repo} ${iproute2_cwd}",
	}
	exec { 'sch_dualpi2-download':
		require => Exec['apt-update'],
		creates => $kernel_module_cwd,
		command => "git clone ${kernel_module_repo} ${kernel_module_cwd}",
	}
	# Somehow using TMPDIR as bash variable is a problem in the vagrant box
	exec { 'iproute2':
		require => Exec['iproute2-download'],
		cwd => $iproute2_cwd,
		path => "${default_path}:${iproute2_cwd}",
		command => "git checkout ${version} &&\
			    sed -i -e 's/TMPDIR/TEMPDIR/g' ${iproute2_cwd}/configure &&\
			    configure &&\
			    make &&\
			    make install;",
	}
	exec {'sch_dualpi2':
		require => [ Exec['iproute2'], Exec['sch_dualpi2-download'] ],
		cwd => $kernel_module_cwd,
		command => "make && make load &&\
								echo \"sudo insmod ${kernel_module_cwd}/sch_dualpi2.ko 2> /dev/null || true\" > ${user_path}/.bashrc"
	}
}

