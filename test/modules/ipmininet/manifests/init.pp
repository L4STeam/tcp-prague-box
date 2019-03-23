
class ipmininet (
	String $install_path = '/home/vagrant',
	String $user = 'vagrant',
) {
	$ipmininet_cwd = "${install_path}/ipmininet"
	$ipmininet_repo = "https://github.com/oliviertilmans/ipmininet.git"

	package { 'mininet': }

	exec { 'ipmininet':
		require => [ Class['common'], Package['mininet'] ],
		creates => $ipmininet_cwd,
		command => "git clone ${ipmininet_repo} ${ipmininet_cwd} &&\
					chown -R ${user}:${user} ${ipmininet_cwd} &&\
					pip install -e ${ipmininet_cwd}",
	}
}
