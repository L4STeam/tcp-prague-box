
class common {
	package { 'git': }
	package { 'pkg-config': }
	package { 'bison': }
	package { 'flex': }
	package { 'python': }
	package { 'libelf-dev': } # Needed for Virtualbox guest additions on kernels above 4.14
	package { 'python-pip': }
	package { 'python3': }
	package { 'python3-pip': }
	exec { 'locales':
  	require => Exec['apt-update'],
  	command => "locale-gen en_US.UTF-8; locale-gen fr_BE.UTF-8; update-locale",
	}
	Package { 'gawk': }
	Package { 'libreadline6-dev': }
	Package { 'libtool': }
	Package { 'libc-ares-dev': }
	Package { 'dia': }
	Package { 'texinfo': }
	Package { 'cmake': }
}

