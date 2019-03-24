
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
	Package { 'netperf': }
	Package { 'build-essential': }
	Package { 'libncurses-dev': }
	apt::ppa { 'ppa:ubuntu-toolchain-r/test':}
	Apt::Ppa['ppa:ubuntu-toolchain-r/test'] -> Package['g++-7']
	Package { 'g++-7': }
	Exec { 'gcc-update'
		require => Package['g++-7'],
		command => "sudo update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-7 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-7 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7"
	}
	Package { 'libssl-dev': }
	Package { 'grub2': }
	Package { 'bc': }
	Package { 'kmod': }
	Package { 'libkmod2': }
}

