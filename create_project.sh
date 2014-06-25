#!/bin/bash
clear;

# ---------------------------------------------------------------- #
# The library is loaded
# ---------------------------------------------------------------- #
source ./functions_globals.sh;

# ---------------------------------------------------------------- #
# This place to the project root
# ---------------------------------------------------------------- #
PATH_REPO_SCRIPT=`pwd -P;`;

cd $PATH_REPO_SCRIPT;

# ---------------------------------------------------------------- #
# Fonction   : information_script
# ---------------------------------------------------------------- #
function information_script () {
    information_package;
    cecho "# ----------------------------------------------------------------- #" $COLOR_WHITE;
    cecho "#                           CREATE PROJECT                          #" $COLOR_WHITE;
    cecho "# ----------------------------------------------------------------- #" $COLOR_WHITE;

    cecho "\n" $COLOR_WHITE;
}

# ---------------------------------------------------------------- #
# Fonction   : get_information_project
# ---------------------------------------------------------------- #
function get_information_project () {
    # ---------------------------------------------------------------- #
    # Choice technologie
    # ---------------------------------------------------------------- #
    case $CHOICE_TECHNOLOGY in
        typo3)
            DUMMY_PROJECT_PATH_DUMMY=$DUMMY_PATH;
            DUMMY_PROJECT_DB_NAME=$DUMMY_DB_NAME;
            DUMMY_PROJECT_DOMAIN=$DUMMY_DOMAIN;
        ;;
    esac

    TECHNOLOGY_UP_CASE=`echo $CHOICE_TECHNOLOGY | tr '[:lower:]' '[:upper:]'`;
    TECHNOLOGY_LOW_CASE=`echo $CHOICE_TECHNOLOGY | tr '[:upper:]' '[:lower:]'`;

    # ---------------------------------------------------------------- #
    # Project folder name
    # ---------------------------------------------------------------- #
    cecho "Enter the folder name " $COLOR_BLUE -n;
    cecho "([a-zA-Z0-9], lowercase, without special characters and 13 characters maximum)" $COLOR_YELLOW -n;
    cecho ": " $COLOR_BLUE -n;
    read CREATE_PROJECT_FOLDER;

    while [ -z $CREATE_PROJECT_FOLDER ] || [ ${#CREATE_PROJECT_FOLDER} -gt 13 ];
    do
        cecho "Enter the folder name " $COLOR_BLUE -n;
        cecho "([a-zA-Z0-9], lowercase, without special characters and 13 characters maximum)" $COLOR_YELLOW -n;
        cecho "(MANDATORY)" $COLOR_RED -n;
        cecho ": " $COLOR_BLUE -n;
        read CREATE_PROJECT_FOLDER;
    done

    CREATE_PROJECT_FOLDER=`echo $CREATE_PROJECT_FOLDER | tr '[:upper:]' '[:lower:]'`;
    CREATE_PROJECT_DB_NAME=$PREFIX_DB"_"$TECHNOLOGY_LOW_CASE"_"$CREATE_PROJECT_FOLDER;
    CREATE_PROJECT_DOMAIN="$CREATE_PROJECT_FOLDER.$SUFFIX_URL";
    CREATE_PROJECT_PATH="$PATH_WWW_FOLDER$TECHNOLOGY_LOW_CASE/$CREATE_PROJECT_FOLDER/";

    cecho "\n" $COLOR_WHITE;

    # ---------------------------------------------------------------- #
    # Wanted if the project already exists
    # ---------------------------------------------------------------- #
    SEARCH_FOLDER_PROJECT=`ls $PATH_WWW_FOLDER/$TECHNOLOGY_LOW_CASE/* | grep $CREATE_PROJECT_FOLDER`;

    SEARCH_VHOST_PROJECT=`ls $SERVER_PATH_SITES_AVAILABLE/* | grep $CREATE_PROJECT_FOLDER`;

    if [ ! -z "$SEARCH_FOLDER_PROJECT" ] || [ ! -z "$SEARCH_VHOST_PROJECT" ]
    then
        errorException $ERROR_STANDARD "Project already exists.";
    fi

    cecho "\n" $COLOR_WHITE;
}

# ---------------------------------------------------------------- #
# Fonction   : valid_information_project
# ---------------------------------------------------------------- #
function valid_information_project () {
    # ---------------------------------------------------------------- #
    # Displays project information
    # ---------------------------------------------------------------- #
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho "--                             CONFIRMATION                             --" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Technology               : $TECHNOLOGY_LOW_CASE" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Dummy project :" $COLOR_WHITE;
    cecho "   - folder               : $DUMMY_PROJECT_PATH_DUMMY" $COLOR_WHITE;
    cecho "   - name of the database : $DUMMY_PROJECT_DB_NAME" $COLOR_WHITE;
    cecho "   - domain name          : $DUMMY_PROJECT_DOMAIN" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " New project :" $COLOR_WHITE;
    cecho "   - folder               : $CREATE_PROJECT_FOLDER" $COLOR_WHITE;
    cecho "   - folder path          : $CREATE_PROJECT_PATH" $COLOR_WHITE;
    cecho "   - name of the database : $CREATE_PROJECT_DB_NAME" $COLOR_WHITE;
    cecho "   - domain name          : $CREATE_PROJECT_DOMAIN" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;

    cecho "\n" $COLOR_WHITE;

    # ---------------------------------------------------------------- #
    # Validation information for the new project
    # ---------------------------------------------------------------- #
    cecho "Is that right?" $COLOR_BLUE;
    select choix_correct_1 in yes no
    do
        case $choix_correct_1 in
            yes)
                break
            ;;
            no)
                die;
                break
            ;;
            *)
                cecho "A choice from the list, please" $COLOR_RED;
            ;;
        esac
    done

    cecho "\n" $COLOR_WHITE;
}

# ---------------------------------------------------------------- #
# Fonction   : create_project
# ---------------------------------------------------------------- #
function create_project () {
    # ---------------------------------------------------------------- #
    # Create new folder
    # ---------------------------------------------------------------- #
    mkdir -p $CREATE_PROJECT_PATH;

    cd $CREATE_PROJECT_PATH;

    # ---------------------------------------------------------------- #
    # Copy of the dummy
    # ---------------------------------------------------------------- #
    rsync -avzP --exclude 'typo3temp/*'  $DUMMY_PROJECT_PATH_DUMMY $CREATE_PROJECT_PATH;

    # ---------------------------------------------------------------- #
    # Dump mysql DB dummy
    # ---------------------------------------------------------------- #
    DUMMY_PROJECT_DB_NAME_TMP="db_$CREATE_PROJECT_DB_NAME.sql";
    mysqldump -u $MYSQL_LOGIN -p$MYSQL_PASSWORD $DUMMY_PROJECT_DB_NAME > $DUMMY_PROJECT_DB_NAME_TMP;

    # ---------------------------------------------------------------- #
    # Domain replaces dummy
    # ---------------------------------------------------------------- #
    if [ "$(uname)" == "Darwin" ];
    then
      sed -i '' -e "s/$DUMMY_PROJECT_DB_NAME/$CREATE_PROJECT_DB_NAME/g" typo3conf/AdditionalConfiguration.php
      sed -i '' -e "s/$DUMMY_PROJECT_DB_NAME/$CREATE_PROJECT_DB_NAME/g" typo3conf/AdditionalConfiguration_dist.php
      sed -i '' -e "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/ext_typoscript_constants_local.txt
      sed -i '' -e "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/ext_typoscript_constants_local_dist.txt
      sed -i '' -e "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/Classes/Utility/realurl_local.php
      sed -i '' -e "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/Classes/Utility/realurl_local_dist.php
    else
      sed -i "s/$DUMMY_PROJECT_DB_NAME/$CREATE_PROJECT_DB_NAME/g" typo3conf/AdditionalConfiguration.php
      sed -i "s/$DUMMY_PROJECT_DB_NAME/$CREATE_PROJECT_DB_NAME/g" typo3conf/AdditionalConfiguration_dist.php
      sed -i "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/ext_typoscript_constants_local.txt
      sed -i "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/ext_typoscript_constants_local_dist.txt
      sed -i "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/Classes/Utility/realurl_local.php
      sed -i "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" typo3conf/ext/skin/Classes/Utility/realurl_local_dist.php
      sed -i "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" ./$DUMMY_PROJECT_DB_NAME_TMP;
    fi

    # ---------------------------------------------------------------- #
    # Create DB
    # ---------------------------------------------------------------- #
    mysqladmin -u $MYSQL_LOGIN -p$MYSQL_PASSWORD create $CREATE_PROJECT_DB_NAME;

    # ---------------------------------------------------------------- #
    # Injected DB
    # ---------------------------------------------------------------- #
    mysql -u $MYSQL_LOGIN -p$MYSQL_PASSWORD $CREATE_PROJECT_DB_NAME < $DUMMY_PROJECT_DB_NAME_TMP;


    # ---------------------------------------------------------------- #
    # Update permission
    # ---------------------------------------------------------------- #
    chown -R $SESSION:$GROUP $CREATE_PROJECT_PATH;
    find $CREATE_PROJECT_PATH -type f -exec /bin/chmod 660 {} \;
    find $CREATE_PROJECT_PATH -type d -exec /bin/chmod 770 {} \;

    create_vhost;

    # ---------------------------------------------------------------- #
    # Update file hosts
    # ---------------------------------------------------------------- #
    FILE_HOSTS=`cat /etc/hosts | grep "$CREATE_PROJECT_DOMAIN"`;

    if [ -z "$FILE_HOSTS" ]; then
        echo "127.0.0.1 $CREATE_PROJECT_DOMAIN" >> /etc/hosts;
    fi
}

# ---------------------------------------------------------------- #
# Fonction   : information_project
# ---------------------------------------------------------------- #
function information_project () {
    # ---------------------------------------------------------------- #
    # Displays project information
    # ---------------------------------------------------------------- #
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho "--                             INFORMATION                              --" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Technology           : $TECHNOLOGY_LOW_CASE" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " New project :" $COLOR_WHITE;
    cecho "   - folder           : $CREATE_PROJECT_FOLDER" $COLOR_WHITE;
    cecho "   - folder path : $CREATE_PROJECT_PATH" $COLOR_WHITE;
    cecho "   - name of the database     : $CREATE_PROJECT_DB_NAME" $COLOR_WHITE;
    cecho "   - domain name    : $CREATE_PROJECT_DOMAIN" $COLOR_WHITE;
    if [ ! -z "$SERVER_VHOST" ]; then
        cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
        cecho " VHost " $COLOR_WHITE;
        cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
        cecho "$SERVER_VHOST" $COLOR_WHITE;
    fi
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;

    cecho "\n" $COLOR_WHITE;

    die "Have fun :)";
}

# ---------------------------------------------------------------- #
# Start of the script
# ---------------------------------------------------------------- #
information_script;

must_be_root;

init_global_vars;

get_information_project;

valid_information_project;

create_project;

information_project;

# ---------------------------------------------------------------- #
# End of the script
# ---------------------------------------------------------------- #
