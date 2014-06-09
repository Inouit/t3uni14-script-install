<VirtualHost *:80>
        ServerAdmin email_server_admin

        ServerName project_domain
        ServerAlias *.project_domain

        DocumentRoot path_project_folder
        <Directory path_project_folder>
                AllowOverride All

                Order Deny,Allow
                Deny from All

                ### IP Local ###
                Allow from 127.0.0.1/32

                AuthType Basic
                AuthUserFile path_project_folder.htpasswd
                AuthName "Local Environment - Project \"project_name\" Restricted Access"
                Require valid-user

                Satisfy any
        </Directory>

        ErrorLog path_log_folderproject_domain-error.log
        CustomLog path_log_folderproject_domain-access.log combined

        ServerSignature Off
</VirtualHost>