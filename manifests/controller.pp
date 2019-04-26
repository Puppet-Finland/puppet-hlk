# @summary setup a combined Windows HLK ("Hardware Lab Kit") Controller / Studio node.
#
# @param installer_source
#   Location of the HLK installer (on puppet fileserver)
# @param hlk_user
#   Name of the user created for accessing the HLK client installer Samba share.
# @param hlk_user_password
#   Password for the HLK user
# @param hlk_controller_address
#   IP or hostname of the HLK controller. Used by HLK clients to configure the Samba share.
#
class hlk::controller
(
  String $installer_source,
  String $hlk_user_password,
  String $hlk_user = 'hlkclient',
  String $hlk_controller_address = $::fqdn
)
{
  $hlk_installer = 'HLKSetup.exe'
  $hlk_installer_path = "C:/ProgramData/${hlk_installer}"

  file { $hlk_installer:
    ensure => 'present',
    name   => $hlk_installer_path,
    source => $installer_source
  }

  package { $hlk_installer:
    ensure          => 'present',
    name            => 'Windows Hardware Lab Kit - Windows 10',
    provider        => 'windows',
    source          => $hlk_installer_path,
    install_options => ['/q', '/features', '+'],
    require         => File[$hlk_installer],
  }

  # Export the HLKInstall SMB share to HLK clients from where they install the 
  # HLC client software:
  #
  # <https://docs.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-2--install-client-on-the-test-system-s->
  #
  dsc_user { $hlk_user:
    dsc_ensure               => present,
    dsc_username             => $hlk_user,
    dsc_description          => $hlk_user,
    dsc_passwordneverexpires => true,
    dsc_disabled             => false,
    dsc_password             =>
    {
        'user'     => $hlk_user,
        'password' => Sensitive($hlk_user_password),
    },
  }

  @@mount { 'R:':
    ensure   => mounted,
    provider => windows_smb,
    device   => "//${hlk_controller_address}/HLKInstall",
    # We need to pass this to the provider or it will choke
    options  => "{\"user\":\"${hlk_user}\",\"password\":\"${hlk_user_password}\"}",
    before   => Package['Windows Hardware Lab Kit Client'],
    tag      => 'hlk_controller',
  }
}
