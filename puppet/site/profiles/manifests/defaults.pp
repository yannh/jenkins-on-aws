class profiles::defaults {
  package {
    ["daemon", "git", "openntpd"]:
      ensure => installed;
  }

  class {
    "java":
      ;
  }
}
