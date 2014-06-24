#!/bin/bash
clear;

# Colors
COLOR_RED="\033[31m";     # Error
COLOR_GREEN="\033[32m";   # Valid
COLOR_YELLOW="\033[33m";  # Comment
COLOR_BLUE="\033[34m";    # Question
COLOR_WHITE="\033[37m";   # Default

# Errors
NOT_ERROR=0;
ERROR_STANDARD=1;
ERROR_COMMAND_NOT_FOUND=127;
SLEEP_NUMBER=3;

# ---------------------------------------------------------------- #
# Fonction   : strpos
# Parametres
#   - 1 ($1) : "string"
#   - 2 ($2) : "string_search"
# ---------------------------------------------------------------- #
function strpos () {
    typeset s1="$1";
    typeset s2="$2";

    if [[ ${#s2} == 0 ]]; then
        return 0;
    fi

    typeset len=${#s1};
    typeset first=${s1%%${s2}*}x;

    typeset ndx=${#first};
    if (( ndx > len )); then
        return 0;
    fi
    return $ndx;
}

# ---------------------------------------------------------------- #
# Fonction : cecho
# Parametres
#   - 1 ($1) : "string"
#   - 2 ($2) : "color"
#   - 3 ($3) : "param pour echo"
# ---------------------------------------------------------------- #
function cecho () {
    local default_msg="No message passed.";
    local default_option="";

    # Defaults to default message.
    message=${1:-$default_msg};

    # Defaults to black, if not specified.
    color=${2:-$black};

    # Defaults to default message.
    options=${3:-$default_option};

    echo -e $3 "$color$message";

    # Reset text attributes to normal + without clearing screen.
    tput sgr0;

    return;
}

# ---------------------------------------------------------------- #
# Fonction : information_package
# ---------------------------------------------------------------- #
function information_package () {
    cecho "# ------------------------------------------------------------------------ #" $COLOR_WHITE;
    cecho "#                            SCRIPTS WEB PROJECT                           #" $COLOR_WHITE;
    cecho "#                                  ------                                  #" $COLOR_WHITE;
    cecho "#                                  v1.0.2                                  #" $COLOR_WHITE;
    cecho "#                                  ------                                  #" $COLOR_WHITE;
    cecho "#                An innovative experiment proposed by INOUIT               #" $COLOR_WHITE;
    cecho "# ------------------------------------------------------------------------ #" $COLOR_WHITE;
}

# ---------------------------------------------------------------- #
# Functoin : errorException
# Parameters
#   - 1 ($1) : "Error code"
#   - 2 ($2) : "Error message"
# ---------------------------------------------------------------- #
function errorException () {
    if [ "$2" ]; then
        cecho "Exception : $2" $COLOR_RED;
    else
        cecho "Exception !" $COLOR_RED;
    fi
    sleep $SLEEP_NUMBER;
    false;
    exit $1;
}

# ---------------------------------------------------------------- #
# Functoin : die
# Parameters
#   - 1 ($1) : "Die message"
# ---------------------------------------------------------------- #
function die () {
    cecho "# ------------------------------------------------------------------------ #" $COLOR_YELLOW;
    cecho "#                                 Goodbye                                  #" $COLOR_YELLOW;
    cecho "# ------------------------------------------------------------------------ #" $COLOR_YELLOW;
    if [ "$1" ]; then
        cecho "# ------------------------------------------------------------------------ #" $COLOR_YELLOW;
        cecho "# $1 " $COLOR_YELLOW;
        cecho "# ------------------------------------------------------------------------ #" $COLOR_YELLOW;
    fi
    sleep $SLEEP_NUMBER;
    false;
    exit $NOT_ERROR;
}

# ---------------------------------------------------------------- #
# Fonction : must_be_root
# ---------------------------------------------------------------- #
function must_be_root () {
    if [ ! "`id 2>&1 | egrep 'uid=0' | cut -d '(' -f1`" = "uid=0" ]; then
        errorException $ERROR_STANDARD "This script must be run as the user 'root'";
    fi
}

# ---------------------------------------------------------------- #
# Fonction : file_parameters_exist
# ---------------------------------------------------------------- #
function file_parameters_exist () {
    PATH_PARAMETERS=$(readlink -f parameters);

    if [ -e $PATH_PARAMETERS ]; then
        source $PATH_PARAMETERS;
    else
        errorException $ERROR_STANDARD "Unable to load the following file $PATH_PARAMETERS";
    fi
}

# ---------------------------------------------------------------- #
# Fonction : get_session_user
# ---------------------------------------------------------------- #
function get_session_user () {
    FIND_SESSION=`cat /etc/passwd | grep '1000' | cut -d ":" -f1`;
    cecho "Enter the name of your session [$FIND_SESSION]: " $COLOR_BLUE -n;

    read SESSION;

    if [ ! -z "$SESSION" ]; then
        findUser=`cat /etc/passwd | grep $SESSION`;
    else
        SESSION=$FIND_SESSION
        FIND_USER=`cat /etc/passwd | grep $SESSION`;
    fi

    while [ -z "$SESSION" ] || [ -z "$FIND_USER" ];
    do
        if [ -z "$SESSION" ]; then
            cecho "Enter the name of your session " $COLOR_BLUE -n;
            cecho "(MANDATORY)" $COLOR_RED -n;
            cecho ": " $COLOR_BLUE -n;
        elif [ -z "$FIND_USER" ]; then
            cecho "The user "$SESSION" does not exist on this system." $COLOR_RED;
            cecho "Enter the name of your session " $COLOR_BLUE -n;
            cecho "(MANDATORY)" $COLOR_RED -n;
            cecho ": " $COLOR_BLUE -n;
        fi

        read SESSION;

        if [ ! -z "$SESSION" ]; then
            FIND_USER=`cat /etc/passwd | grep $SESSION`;
        fi
    done

    cecho "\n" $COLOR_WHITE;
}

# ---------------------------------------------------------------- #
# Fonction   : init_global_vars
# ---------------------------------------------------------------- #
function init_global_vars () {
    CHOICE_TECHNOLOGY="typo3";
    SERVER_NAME="apache2";
    SERVER_VHOST="";

    # ---------------------------------------------------------------- #
    # Init file parameters
    # ---------------------------------------------------------------- #
    file_parameters_exist;

    # ---------------------------------------------------------------- #
    # Retrieve the name of the user session
    # ---------------------------------------------------------------- #
    get_session_user;
}

# ---------------------------------------------------------------- #
# Fonction   : create_vhost
# ---------------------------------------------------------------- #
function create_vhost () {
    cd $CREATE_PROJECT_PATH;

    case $SERVER_NAME in
        apache2)
            local CREATE_PROJECT_VIRTUAL_HOST="/etc/$SERVER_NAME/sites-available/$CREATE_PROJECT_DOMAIN";

            # ---------------------------------------------------------------- #
            # Create Vhost
            # ---------------------------------------------------------------- #
            cp "$PATH_REPO_SCRIPT/skeletons/$SERVER_NAME/skeleton_$TECHNOLOGY_LOW_CASE.local.com" $CREATE_PROJECT_VIRTUAL_HOST;
            sed -i "s/email_server_admin/$EMAIL_SERVER_ADMIN/g" $CREATE_PROJECT_VIRTUAL_HOST;
            sed -i "s/project_domain/$CREATE_PROJECT_DOMAIN/g" $CREATE_PROJECT_VIRTUAL_HOST;
            sed -i "s/project_name/$CREATE_PROJECT_FOLDER/g" $CREATE_PROJECT_VIRTUAL_HOST;
            CREATE_PROJECT_PATH_SLASH=`echo $CREATE_PROJECT_PATH | sed 's/\//\\\\\//g'`;
            sed -i "s/path_project_folder/$CREATE_PROJECT_PATH_SLASH/g" $CREATE_PROJECT_VIRTUAL_HOST;
            PATH_LOG_FOLDER_SLASH=`echo $PATH_LOG_FOLDER | sed 's/\//\\\\\//g'`;
            sed -i "s/path_log_folder/$PATH_LOG_FOLDER_SLASH/g" $CREATE_PROJECT_VIRTUAL_HOST;

            SERVER_VHOST=$(cat "$CREATE_PROJECT_VIRTUAL_HOST");

            # ---------------------------------------------------------------- #
            # Enabled vhost
            # ---------------------------------------------------------------- #
            cd $SERVER_PATH_SITES_ENABLED;
            ln -s $SERVER_PATH_SITES_AVAILABLE$CREATE_PROJECT_DOMAIN $CREATE_PROJECT_DOMAIN;

            $SERVER_COMMAND_RESTART;
        ;;
    esac

    cd $CREATE_PROJECT_PATH;
}