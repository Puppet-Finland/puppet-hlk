# Reference
<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

**Classes**

* [`hlk::client`](#hlkclient): setup Windows Hardware Lab Kit ("HLK") client
* [`hlk::controller`](#hlkcontroller): setup a combined Windows HLK ("Hardware Lab Kit") Controller / Studio node.

## Classes

### hlk::client

setup Windows Hardware Lab Kit ("HLK") client

#### Parameters

The following parameters are available in the `hlk::client` class.

##### `testcert`

Data type: `String`

File name of the test certificate

##### `testcert_source`

Data type: `String`

Test certificate location (on the puppet fileserver)

### hlk::controller

setup a combined Windows HLK ("Hardware Lab Kit") Controller / Studio node.

#### Parameters

The following parameters are available in the `hlk::controller` class.

##### `installer_source`

Data type: `String`

Location of the HLK installer (on puppet fileserver)

##### `hlk_user`

Data type: `String`

Name of the user created for accessing the HLK client installer Samba share.

Default value: 'hlkclient'

##### `hlk_user_password`

Data type: `String`

Password for the HLK user

##### `hlk_controller_address`

Data type: `String`

IP or hostname of the HLK controller. Used by HLK clients to configure the Samba share.

Default value: $::fqdn
