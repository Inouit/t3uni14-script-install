t3uni14-script-install
======================
t3Uni14 presentation : Optimize your development time in Typo3 - Installation script project


## Requirements ##
**A draft typo3 dummy generic should be already installed** [Inouit/dummyGeneric6](https://github.com/Inouit/dummyGeneric6).


## Installation ##
 - Clone Project
```
git clone git@github.com:Inouit/t3uni14-script-install.git;
```
 - Go to the project root
```
cd ./t3uni14-script-install/;
```
 - Duplicate and rename the file parameters.dist into parameters to the project root
```
## For Debian
cp ./parameters.dist ./parameters;
```
 - Fill informations
```
# MYSQL
MYSQL_LOGIN="login_root"
MYSQL_PASSWORD="password_root"

# Server
SERVER_PATH_SITES_AVAILABLE="/etc/apache2/sites-available/"
SERVER_PATH_SITES_ENABLED="/etc/apache2/sites-enabled/"
SERVER_COMMAND_RESTART="/etc/init.d/apache2 restart"
EMAIL_SERVER_ADMIN="network@local.com"
PATH_WWW_FOLDER="/var/www/"
PATH_LOG_FOLDER="/var/log/apache2/"

# Information for technologie
PREFIX_DB="local"
SUFFIX_URL="local.com"
    # TYPO3
TYPO3_PATH_DUMMY="/var/www/typo3/dummy/"
TYPO3_DB_NAME="local_typo3_dummy"
TYPO3_DOMAIN="dummy.local.com"
```
 - Run the script with root privileges
```
## For Debian
su root;
./create_project.sh;
```
 - Follow the steps and enjoy


## Changelog ##
- 1.0.3: Fix script for MAC OS
- 1.0.2: Adding the documentation
- 1.0.1: Translation of content
- 1.0.0: Adding script "create propject"

---
[MIT License](LICENSE). © Inouit (http://www.inouit.fr/).