class profiles::defaults {
  package {
    ['daemon', 'git', 'openntpd', 'unattended-upgrades']:
      ensure => installed;
  }

  class {
    'java':
      ;
  }
}
