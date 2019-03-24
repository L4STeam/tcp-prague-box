# The purpose of this puppet file is to install TCP prague kernel and some emulation tools

$home_path="/home/vagrant"
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

class { 'tcp_prague_kernel': }

