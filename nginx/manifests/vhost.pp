# Define: nginx::vhost
#
# arguments
#
define nginx::vhost (

	$app_root_www, $nginx_config_dir, $error_log_dir, $access_log_dir, $vhost_config_dir, $passenger_config_dir

	) {
	# puppet code

	file { ['/var/www',
			'/var/www/myapp',
			'/var/www/myapp/code']:
		ensure => directory,
	}

	file { 'nginx-conf':
		ensure => file,
		path   => "${nginx_config_dir}/nginx.conf",
		source => 'puppet:///modules/nginx/nginx.conf',
		before => [File['passenger-conf'], File['app-conf']],
	}

	file { 'passenger-conf':
		ensure  => file,
		path    => "${passenger_config_dir}/passenger.conf",
		source  => 'puppet:///modules/nginx/passenger.conf',
		before  => File['app-conf'],
	}

	file { 'app-conf':
		ensure   => file,
		path     => "${vhost_config_dir}/app.conf",
		content  => template('nginx/app.conf.erb'),
	} ->

	vcsrepo {$app_root_www:
		ensure    => present,
		provider  => git,
		revision  => master,
		force     => true,
		notify    => Service['nginx'],
		source    => 'https://github.com/phusion/passenger-nodejs-connect-demo.git',
	} ->

	exec { 'run-app':
		command      => 'npm install --production',
		path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
		cwd          => $app_root_www,
		#user        => 'user_to_run_as',
		#unless      => 'test param-that-would-be-true',
		#refreshonly => true,
	}
}