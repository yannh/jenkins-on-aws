class profiles::jenkins_master {
  class {
    'jenkins':
      repo            => false,
      direct_download => 'https://pkg.jenkins.io/debian-stable/binary/jenkins_2.19.4_all.deb',
      install_java    => false,
      require         => [Package['daemon'], Class['java']];

  }

  file {
    '/usr/local/bin/snapshot-ebs.sh':
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('profiles/snapshot-ebs.sh');
  }

  cron {
    'SnapshotJenkinsVolumeCron':
      command => '/usr/local/bin/snapshot-ebs.sh 2>&1 >/dev/null | /usr/bin/logger -t snapshot-ebs',
      user    => 'root',
      hour    => 3,
      minute  => 31,
  }
}
