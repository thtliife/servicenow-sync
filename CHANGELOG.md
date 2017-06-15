
___
##  Historical changes

### 0.2.17 - *2017-04-22*

*   Fixed changelog to keep versions inline

### 0.2.16 - *2017-04-22*

*   Add support for table and field in the Service Portal Widget, Page, CSS and
angular providers (thanks [vr-fox](https://github.com/vr-fox))

### 0.2.13 - *2016-10-31*

*   Fixed some variable styles to ensure compatibility with coffeescript v1.11.0
(new coffeescript version for atom v1.12)

### 0.2.12 - *2016-08-15*

*   Fixed [an issue](https://github.com/thtliife/servicenow-sync/issues/3) which
caused tables with multiple fields for storing scripts to be saved incorrectly.

### 0.2.11 - *2016-07-29*

*   Updated dependency `request` to resolve vulnerability noted [at snyk](https://snyk.io/vuln/npm:tough-cookie:20160722)

### 0.2.10 - *2016-06-21*

*   Removed superfluous logging when debug mode not enabled

### 0.2.9 - *2016-06-21*

*   Fixed a bug introduced by a bad check for null instead of null or undefined
on v0.2.8

### 0.2.8 - *2016-06-21*

*   Fixed a bug which caused errors activating the plugin on Windows ([Issue #1](https://github.com/thtliife/servicenow-sync/issues/1))

### 0.2.7 - *2016-06-03*

*   Fixed bug where url-encoded ampersand (%26) broke pasted url in file
    settings for sys_id

### 0.2.6 - *2016-05-25*

*   Fixed deprecated selectors for editor and mini-editor
*   Fixed creation of tableConfig.user.cson file on windows 7

### 0.2.5 - *2016-05-09*

*   Fixed some further styling bugs if using seti ui theme

### 0.2.4 - *2016-05-09*

*   Fixed some styling bugs if using seti ui theme

*   Added ability to use custom tables for table and fieldName via
    `config/tableConfig.user.cson`

### 0.2.3 - *2016-04-27*

*   Fixed error in "Get Info" function in configure panel when no description
    exists for a remote file

### 0.2.2 - *2016-04-27*

*   Fixed Readme formatting

### 0.2.1 - *2016-04-27*

*   Updated Readme

### 0.2.0 - *2016-04-27*

*   Added ability to view the remote file in users browser

*   Updated readme with new feature and link to atom package page for
    ServcienowSync

### 0.1.0 - Initial Release *2016-04-21*

*   Every feature added
