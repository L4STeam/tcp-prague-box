class quagga (
	String $install_path = '/home/vagrant',
	String $user = 'vagrant',
) {
	
  $quagga_version = "1.2.2"
  $quagga_release_url = "http://download.savannah.gnu.org/releases/quagga/quagga-${quagga_version}.tar.gz"
  $quagga_root_dir = $install_path
  $quagga_source_path = "${quagga_root_dir}/quagga-${quagga_version}"
  $quagga_download_path = "${quagga_source_path}.tar.gz"
  $quagga_path = "${install_path}/quagga"

	exec { 'quagga-download':
    creates => $quagga_source_path,
    command => "wget -O - ${quagga_release_url} > ${quagga_download_path} &&\
                tar -xvzf ${quagga_download_path} -C ${quagga_root_dir};"
  }

	exec { 'quagga':
		require => [ Class['common'], Exec['quagga-download'] ],
		creates => $quagga_path,
		cwd => $quagga_source_path,
		command => "${quagga_source_path}/configure --prefix=${quagga_path} &&\
                make &&\
                make install &&\
                rm ${quagga_download_path} &&\
                echo \"# quagga binaries\" >> /etc/profile &&\
                echo \"PATH=\\\"${quagga_path}/bin:${quagga_path}/sbin:\\\$PATH\\\"\" >> /etc/profile &&\
                echo \"alias sudo=\'sudo env \\\"PATH=\\\$PATH\\\"\'\" >> /etc/profile &&\
                echo \"# quagga binaries\" >> /root/.bashrc &&\
                echo \"PATH=\\\"${quagga_path}/bin:${quagga_path}/sbin:\\\$PATH\\\"\" >> /root/.bashrc &&\
                PATH=${quagga_path}/sbin:${quagga_path}/bin:\$PATH;",
	}

  group { quagga:
    ensure => 'present',
  }
  user { '${user}':
    groups => 'quagga',
  }
  user { 'root':
    groups => 'quagga',
  }
}
