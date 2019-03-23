# The purpose of this puppet file is to install SRv6-compatible kernel and some SRv6 tools

# TODO Remove
$non_root_user=vagrant
# TODO Remove

$home_path="/home/${::non_root_user}"
$default_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Package {
	allow_virtual => true,
	ensure => installed,
	require => Exec['apt-update'],
}
Exec { path => $default_path }

exec { 'apt-update':
  command => 'apt-get update',
}

class { 'common': }

class { 'aqmqdisc':
	require => [ Class['common'], Class['ipmininet'] ],
}

class { 'ipmininet':
	require => Class['common'],
}

class { 'quagga':
	require => Class['common'],
}

class { 'picoquic':
	require => Class['common'],
}

# TODO
#class { 'tcp_prague_kernel':
#	package_path => $::kernel_path,
#	kernel_version => $::kernel_version,
#	local_version => $::kernel_local_version,
#	kdeb_version => $::kernel_kdeb_version,
#}

# TODO sch_dualpi2_upstream
# TODO 

