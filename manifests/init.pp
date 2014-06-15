class apache::install {

    package { 'apache2' :
        ensure => installed,
        require => Class['php']
    }
}

class apache::configure {
    
}

class apache::run {
    service { apache2:
        enable => true,
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        require => Class['apache::install', 'apache::configure'],
    }
}

define addServer( $site, $root ) {
    $sitesavailable = '/etc/apache2/sites-available'
    $template = 'apache/vhost.erb'
    $server_name = "$site"

    file {"$sitesavailable/$site":
        content => template($template),
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        require => Package['apache2'],
        notify  => Service['apache2']
    }

    exec {"a2ensite $site":
        command => '/usr/bin/a2ensite $site',
        require => File["$sitesavailable/$site"],
    }
}

class apache {
    include apache::install
    include apache::configure
    include apache::run
}