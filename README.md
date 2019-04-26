
# puppet-hlk

A Puppet module for setting up Windows Hardware Lab Kit (HLK) studio,
controller and client systems.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with hlk](#setup)
    * [What hlk affects](#what-hlk-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)

## Description

This module can fully configure HLK controllers and HLK clients.

## Setup

### What hlk affects

The ::hlk::controller class install the HLK controller software from the Puppet
fileserver and creates a local Windows user (default: 'hlkclient') for
accessing the HLK client installation medium through a Samba share. Although
the HLKInstall share should be readable by anonymous users, that access seems
to be prone to breakage. The Samba share is created and exported to clients
automatically.

When HLK Controller software is installed it automatically opens up ports 1771
(HLK server receiver) and 1782 (HLKSvc receiver) in the Windows Firewall,
allowing all inbound connections to those ports.

The ::hlk::client class mounts the HLK installation Samba share on client
systems, install the HLK client software from it and installs the driver test
certificate on the system.

Installing HLK Client software puts Windows into test mode automatically, so
it will accept gladly accept such test-signed drivers.

### Setup Requirements

This module depends on [puppetlabs-dsc](https://forge.puppet.com/puppetlabs/dsc)
and [geoffwilliams-mount_windows_smb](https://forge.puppet.com/geoffwilliams/mount_windows_smb).

HLK client systems need to be able to access port 445 on the HLK controller in
order to install the HLK client software.

The $::fqdn fact of the HLK controller is used as part of the HLKInstall Samba
share URI.  This can be overridden with class parameters if the $::fqdn is
something funky. 

### Usage

Setting up HLK controller from a profile:

    class profile::hlk_controller {
    
      $hlk_user = 'hlkclient'
      $hlk_user_password = lookup('hlk_user_password',String)
    
      class { '::hlk::controller':
        installer_source  => 'puppet:///files/HLKSetup.exe',
        hlk_user_password => $hlk_user_password,
        hlk_user          => $hlk_user,
      }
    }

Setting up an HLK client from a profile:

    class profile::hlk_client {

      $testcert = 'tap0901.cer'
      $testcert_source = "puppet:///modules/profile/${testcert}"
    
      class { '::hlk::client':
        testcert        => $testcert,
        testcert_source => $testcert_source,
      }
    }

For details see [REFERENCE.md](REFERENCE.md).
