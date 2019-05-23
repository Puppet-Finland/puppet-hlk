# @summary setup Windows Hardware Lab Kit ("HLK") client
#
# @param testcert
#   File name of the test certificate
# @param testcert_source
#   Test certificate location (on the puppet fileserver)
#
class hlk::client
(
  String $testcert,
  String $testcert_source
)
{
  # Mount the SMB share "HLKInstall" on the controller as user "hlkclient"
  Mount <<| tag == 'hlk_controller' |>>

  # We can't use Setup.cmd with the package resource, but fortunately it is 
  # just a simple wrapper around the actual executable installer.
  $hlk_installer = $::architecture ? {
    'x64' => 'Setupamd64.exe',
    'x86' => 'Setupx86.exe',
  }
  $hlk_description = 'Windows Hardware Lab Kit Client'
  $hlk_installer_path = "R:\\Client\\${hlk_installer}"

  package { $hlk_description:
    ensure          => 'present',
    name            => $hlk_description,
    provider        => 'windows',
    source          => $hlk_installer_path,
    install_options => ['/qn', 'ICFAGREE=Yes'],
  }

  # Install the test certificate for the driver
  file { $testcert:
    ensure => 'present',
    name   => "C:/ProgramData/${testcert}",
    source => $testcert_source,
  }

  dsc_xcertificateimport { $testcert:
    dsc_ensure     => 'present',
    dsc_thumbprint => '80FA0F185744F3AB7C5A63E66CB638CD00CA0F83',
    dsc_path       => "C:/ProgramData/${testcert}",
    dsc_location   => 'LocalMachine',
    dsc_store      => 'TrustedPublisher',
    require        => File[$testcert],
  }

  # Enable test signing
  exec { 'enable-test-signing':
    command  => file('hlk/enable-test-signing.ps1'),
    creates  => 'C:\ProgramData\test-signing-is-enabled',
    provider => powershell,
  }

  reboot { 'after-enabling-test-signing':
    when      => 'refreshed',
    apply     => 'finished',
    message   => 'Rebooting to enable test signing',
    subscribe => Exec['enable-test-signing'],
  }
}
