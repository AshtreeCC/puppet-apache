class apache::install {

    package { 'apache2' :
        ensure => installed,
        require => Class['php']
    }

    package { 'libapache2-mod-php5' :
        ensure => installed,
        require => Package['apache2']
    }
}

class apache::configure {
    exec {"a2enmod rewrite":
        command => '/usr/sbin/a2enmod rewrite',
        require => Package['apache2'],
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
    $sitesenabled = '/etc/apache2/sites-enabled'
    $template = 'apache/vhost.erb'
    $documentRoot = "$root"
    $hostname = "$site"

    file {"$sitesavailable/$site.conf":
        content => template($template),
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        require => Package['apache2'],
        notify  => Service['apache2']
    }

    exec {"a2ensite $site":
        command => '/usr/sbin/a2ensite $site',
        require => File["$sitesavailable/$site.conf"],
    }
}

class apache {
    include apache::install
    include apache::configure
    include apache::run
}
