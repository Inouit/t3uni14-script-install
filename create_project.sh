#!/bin/bash
clear;

# ---------------------------------------------------------------- #
# The library is loaded
# ---------------------------------------------------------------- #
PATH_LIBRARY=$(readlink -f functions_globals.sh);
if [ -e $PATH_LIBRARY ]
then
    source $PATH_LIBRARY;
else
    echo "Impossible de charger le fichier suivant: "$PATH_LIBRARY
    exit 1;
fi

# ---------------------------------------------------------------- #
# This place to the project root
# ---------------------------------------------------------------- #
PATH_SCRIPT=$(readlink -f create_project.sh);
strpos "${PATH_SCRIPT}" "/create_project.sh";
SEARCH_END_CARACTER=$?;
PATH_REPO_SCRIPT=`echo ${PATH_SCRIPT} | cut -c1-${SEARCH_END_CARACTER}`;

cd $PATH_REPO_SCRIPT;

# ---------------------------------------------------------------- #
# Fonction   : information_script
# ---------------------------------------------------------------- #
function information_script () {
    information_package;
    cecho "# ------------------------------------------------------------------------ #" $COLOR_WHITE;
    cecho "#                           CREATION D'UN PROJET                           #" $COLOR_WHITE;
    cecho "# ------------------------------------------------------------------------ #" $COLOR_WHITE;

    cecho "\n" $COLOR_WHITE;
}

# ---------------------------------------------------------------- #
# Fonction   : get_information_project
# ---------------------------------------------------------------- #
function get_information_project () {
    # ---------------------------------------------------------------- #
    # Choice technologie
    # ---------------------------------------------------------------- #
    cecho "Choix de la technologie du projet (ex: typo3): " $COLOR_BLUE;
    select CHOICE_TECHNOLOGY in typo3 sortir
    do
        case $CHOICE_TECHNOLOGY in
            typo3)
                DUMMY_PROJECT_PATH_DUMMY=$TYPO3_PATH_DUMMY;
                DUMMY_PROJECT_DB_NAME=$TYPO3_DB_NAME;
                DUMMY_PROJECT_DOMAIN=$TYPO3_DOMAIN;
                break
            ;;
            sortir)
                die;
                break
            ;;
            *)
                cecho "Un choix de la liste SVP" $COLOR_RED;
            ;;
        esac
    done

    TECHNOLOGY_UP_CASE=`echo $CHOICE_TECHNOLOGY | tr '[:lower:]' '[:upper:]'`;
    TECHNOLOGY_LOW_CASE=`echo $CHOICE_TECHNOLOGY | tr '[:upper:]' '[:lower:]'`;

    cecho "\n" $COLOR_WHITE;

    # ---------------------------------------------------------------- #
    # Project name
    # ---------------------------------------------------------------- #
    cecho "Entrer le nom du projet " $COLOR_BLUE -n;
    cecho "([a-zA-Z0-9])" $COLOR_YELLOW -n;
    cecho ": " $COLOR_BLUE -n;

    while read CREATE_PROJECT_NAME;
    do
        if [[ $CREATE_PROJECT_NAME =~ [[:alnum:]] ]]; then
            break;
        else
            cecho "Entrer le nom du projet " $COLOR_BLUE -n;
            cecho "([a-zA-Z0-9])" $COLOR_YELLOW -n;
            cecho "(OBLIGATOIRE)" $COLOR_RED -n;
            cecho ": " $COLOR_BLUE -n;
        fi
    done

    cecho "\n" $COLOR_WHITE;

    # ---------------------------------------------------------------- #
    # Project folder name
    # ---------------------------------------------------------------- #
    cecho "Entrer le nom du dossier " $COLOR_BLUE -n;
    cecho "([a-zA-Z0-9], en miniscule, sans caractère spéciaux et 13 caractères max)" $COLOR_YELLOW -n;
    cecho ": " $COLOR_BLUE -n;
    read CREATE_PROJECT_FOLDER;

    while [ -z $CREATE_PROJECT_FOLDER ] || [ ${#CREATE_PROJECT_FOLDER} -gt 13 ];
    do
        cecho "Entrer le nom du dossier " $COLOR_BLUE -n;
        cecho "([a-zA-Z0-9], en miniscule, sans caractère spéciaux et 13 caractères max)" $COLOR_YELLOW -n;
        cecho "(OBLIGATOIRE)" $COLOR_RED -n;
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

    SEARCH_VHOST_PROJECT=`ls /etc/apache2/sites-*/* | grep $CREATE_PROJECT_FOLDER`;

    if [ ! -z "$SEARCH_FOLDER_PROJECT" ] || [ ! -z "$SEARCH_VHOST_PROJECT" ]
    then
        errorException $ERROR_STANDARD "Le projet semble déjà existé.";
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
    cecho " Technologie           : $TECHNOLOGY_LOW_CASE" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Projet dummy :" $COLOR_WHITE;
    cecho "   - dossier           : $DUMMY_PROJECT_PATH_DUMMY" $COLOR_WHITE;
    cecho "   - nom de la BDD     : $DUMMY_PROJECT_DB_NAME" $COLOR_WHITE;
    cecho "   - nom de domaine    : $DUMMY_PROJECT_DOMAIN" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Nouveau projet :" $COLOR_WHITE;
    cecho "   - nom du projet     : $CREATE_PROJECT_NAME" $COLOR_WHITE;
    cecho "   - dossier           : $CREATE_PROJECT_FOLDER" $COLOR_WHITE;
    cecho "   - chemin du dossier : $CREATE_PROJECT_PATH" $COLOR_WHITE;
    cecho "   - nom de la BDD     : $CREATE_PROJECT_DB_NAME" $COLOR_WHITE;
    cecho "   - nom de domaine    : $CREATE_PROJECT_DOMAIN" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;

    cecho "\n" $COLOR_WHITE;

    # ---------------------------------------------------------------- #
    # Validation information for the new project
    # ---------------------------------------------------------------- #
    cecho "Est-ce correct ?" $COLOR_BLUE;
    select choix_correct_1 in oui non
    do
        case $choix_correct_1 in
            oui)
                break
            ;;
            non)
                die;
                break
            ;;
            *)
                cecho "Un choix de la liste SVP" $COLOR_RED;
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
    rsync -avz $DUMMY_PROJECT_PATH_DUMMY $CREATE_PROJECT_PATH;

    # ---------------------------------------------------------------- #
    # Dump mysql DB dummy
    # ---------------------------------------------------------------- #
    DUMMY_PROJECT_DB_NAME_TMP="tmp_create_project_$DUMMY_PROJECT_DB_NAME.sql";
    mysqldump -u $MYSQL_LOGIN -p$MYSQL_PASSWORD $DUMMY_PROJECT_DB_NAME > $DUMMY_PROJECT_DB_NAME_TMP;

    # ---------------------------------------------------------------- #
    # Domain replaces dummy
    # ---------------------------------------------------------------- #
    sed -i "s/$DUMMY_PROJECT_DOMAIN/$CREATE_PROJECT_DOMAIN/g" ./$DUMMY_PROJECT_DB_NAME_TMP;

    # ---------------------------------------------------------------- #
    # Create DB
    # ---------------------------------------------------------------- #
    mysqladmin -u $MYSQL_LOGIN -p$MYSQL_PASSWORD create $CREATE_PROJECT_DB_NAME;

    # ---------------------------------------------------------------- #
    # Injected DB
    # ---------------------------------------------------------------- #
    mysql -u $MYSQL_LOGIN -p$MYSQL_PASSWORD $CREATE_PROJECT_DB_NAME < $DUMMY_PROJECT_DB_NAME_TMP;

    # ---------------------------------------------------------------- #
    # Delete DB dummy temporary
    # ---------------------------------------------------------------- #
    rm -rf $DUMMY_PROJECT_DB_NAME_TMP;

    # ---------------------------------------------------------------- #
    # Update permission
    # ---------------------------------------------------------------- #
    chown -R $SESSION:www-data $CREATE_PROJECT_PATH;
    find $CREATE_PROJECT_PATH -type f -exec /bin/chmod 660 {} \;
    find $CREATE_PROJECT_PATH -type d -exec /bin/chmod 770 {} \;

    create_vhost;

    # ---------------------------------------------------------------- #
    # Update file hosts
    # ---------------------------------------------------------------- #
    FILE_HOSTS=`cat /etc/hosts | grep "$CREATE_PROJECT_DOMAIN"`;

    if [ -z "$FILE_HOSTS" ]
    then
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
    cecho "--                             INFORMATIONS                             --" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Technologie           : $TECHNOLOGY_LOW_CASE" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;
    cecho " Nouveau projet :" $COLOR_WHITE;
    cecho "   - nom du projet     : $CREATE_PROJECT_NAME" $COLOR_WHITE;
    cecho "   - dossier           : $CREATE_PROJECT_FOLDER" $COLOR_WHITE;
    cecho "   - chemin du dossier : $CREATE_PROJECT_PATH" $COLOR_WHITE;
    cecho "   - nom de la BDD     : $CREATE_PROJECT_DB_NAME" $COLOR_WHITE;
    cecho "   - nom de domaine    : $CREATE_PROJECT_DOMAIN" $COLOR_WHITE;
    cecho "--------------------------------------------------------------------------" $COLOR_WHITE;

    cecho "\n" $COLOR_WHITE;

    die "Amusez vous bien :)";
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