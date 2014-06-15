class apache::install {

    package { 'apache2-mpm-worker' :
        ensure => installed,
        require => Class['php']
    }

    package { 'libapache2-mod-fastcgi' :
        ensure => installed,
        require => Package['apache2-mpm-worker']
    }
}

class apache::configure {
    
    exec {'a2enmod actions fastcgi alias':
        command => '/usr/bin/a2enmod actions fastcgi alias',
        require => Package['libapache2-mod-fastcgi']
    }

    file { '/etc/apache2/conf.d/php5-fpm.conf':
        content => '
            <IfModule mod_fastcgi.c>
                AddHandler php5-fcgi .php
                Action php5-fcgi /php5-fcgi
                Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
                FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -pass-header Authorization
            </IfModule>',
        require => Exec['a2enmod actions fastcgi alias']
    }
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
        require => Package['apache2-mpm-worker'],
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