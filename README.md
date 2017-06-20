# Servicenow Sync

*Atom integration with [ServiceNow](http://www.servicenow.com) (Eureka & above)*

[Servicenow Sync on atom.io](https://atom.io/packages/servicenow-sync)

[![Wercker](https://img.shields.io/wercker/ci/wercker/docs.svg?maxAge=2592000)](https://github.com/thtliife/servicenow-sync)
[![GitHub issues](https://img.shields.io/github/issues/thtliife/servicenow-sync.svg)](https://github.com/thtliife/servicenow-sync/issues)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/thtliife/servicenow-sync/master/LICENSE.md)

Servicenow Sync is a package primarily for ServiceNow developers.
Servicenow Sync enables direct uploading of files to your ServiceNow instance.

## Features

*   JSONv2 Support
*   Easy configuration via config panel
*   Ability to pull data from your remote ServiceNow instance
*   Enhanced conflict detection between Server and local copy
*   Enhanced messages to the end user on error

<!-- ![servicenow-sync configuration pane](http://i.imgur.com/zatN393.png =500x)
 -->
## Installation

Using apm:

```bash
apm install servicenow-sync
```

Or search for `servicenow-sync` in Atom settings view

## Settings

### Sync on save

If checked the package will upload to your service now instance whenever you
save a file configured as a Service now file.

### Create .gitignore

If checked, the package will create / update a .gitignore file in the same
directory as the file you are editing if you choose to configure the file
for use with service now.
This .gitignore will enable git to ignore the created config file
(\[*filename*\].snsync.cson).

### Debug mode

If checked, the package will output extra debugging information to the console.

## Usage

### Configure your file for Servicenow Sync

Open the [Command Pallette](https://github.com/atom/command-palette), and type
`Servicenow Sync: Configure File` (or `snscf` for faster use thanks to Atoms
awesome fuzzy matching)

You can also use the default key map of `ctrl`+`alt`+`k`

Fill in the settings for your specific instance and file, and click `Retrieve`
to pull the remote file to your editor, or click `OK` to save the settings
without retrieving the remote file.
You may also just paste the URL to the file as retrieved from ServiceNow to
prefill most of the fields for you.
If you leave the `Sys Id` field empty, then a new file will be created upon
pushing to ServiceNow for the first time.

![Configure a file for Servicenow Sync](http://i.imgur.com/d3K2VDp.gif =500px)

### Sync the contents of your editor to ServiceNow

Open the [Command Pallette](https://github.com/atom/command-palette), and type
`Servicenow Sync: Sync` (or the fuzzy matched `sn:sync`)

You can also use the default key map of `ctrl`+`alt`+`l`

*Alternatively, you may just enable the `Sync on save` setting which will push
your editors content to ServiceNow on every save, as long as you have previously
configured the file for Servicenow Sync.*

![Sync to ServiceNow](http://i.imgur.com/TjMcjxP.gif)

### View the current file in your ServiceNow instance

Open the [Command Pallette](https://github.com/atom/command-palette), and type
`Servicenow Sync: View Remote` (or the fuzzy matched `ssvr`)

You can also use the default key map of `ctrl`+`alt`+`v`

This will open your the currently focused file in the configured ServiceNow
instance with your default browser. This obviously requires that the file has
already been configured for Servicenow sync with the
`Servicenow Sync: Configure File` command.

## Further information

### Stored credentials

Credentials are stored as a Base64 encoded string within the settings
for the file.

## Proxy support

Proxies are handled through the http_proxy and https_proxy environment variables
These should be set as follows:

### Windows

use setx *variable_name* *variable_value* at the cmd.exe prompt:

```cmd
setx http_proxy http://proxyaddress.com:3128
setx https_proxy http://proxyaddress.com:80

or if you must authenticate to the proxy...

setx http_proxy http://username:password@proxyaddress.com:3128
setx https_proxy http://username:password@proxyaddress.com:80
```

### Linux/OS X/Unix

Follow the instructions from [nixCraft](http://www.cyberciti.biz/faq/)

[How To Use Proxy Server To Access Internet at Shell Prompt With http_proxy Variable](http://www.cyberciti.biz/faq/linux-unix-set-proxy-environment-variable/)
