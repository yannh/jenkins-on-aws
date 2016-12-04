class profiles::jenkins_slave {
  class {
    'docker':
      ;

    'docker::compose':
      version => '1.8.0';
  }

  user {
    'jenkins':
      ensure     => present,
      home       => '/home/jenkins',
      managehome => true,
      groups     => ['docker'],
      shell      => '/bin/bash',
      require    => Class['docker']
  }

  file {
    '/home/jenkins/.ssh':
      ensure  =>  directory,
      owner   =>  'jenkins',
      group   =>  'jenkins',
      mode    =>  '0700',
      require =>  User['jenkins']
  }

  package {
    ['ruby', 'ruby-dev', 'zlib1g-dev']:
      ensure => installed;

    'deb-s3':
      ensure   => installed,
      provider => gem,
      require  => Package['ruby', 'ruby-dev', 'zlib1g-dev'];
  }
}
