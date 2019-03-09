#!/bin/bash
#---------- see https://github.com/joelong01/Bash-Wizard----------------
# bashWizard version 0.909
# this will make the error text stand out in red - if you are looking at these errors/warnings in the log file
# you can use cat <logFile> to see the text in color.
function echoError() {
    RED=$(tput setaf 1)
    NORMAL=$(tput sgr0)
    echo "${RED}${1}${NORMAL}"
}
function echoWarning() {
    YELLOW=$(tput setaf 3)
    NORMAL=$(tput sgr0)
    echo "${YELLOW}${1}${NORMAL}"
}
function echoInfo {
    GREEN=$(tput setaf 2)
    NORMAL=$(tput sgr0)
    echo "${GREEN}${1}${NORMAL}"
}
# make sure this version of *nix supports the right getopt
! getopt --test 2>/dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echoError "'getopt --test' failed in this environment. please install getopt."
    read -r -p "install getopt using brew? [y,n]" response
    if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
        brew install gnu-getopt
        #shellcheck disable=SC2016
        echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile
        echoWarning "you'll need to restart the shell instance to load the new path"
    fi
   exit 1
fi

function usage() {
    
    echo "Deploys javascript to a edu.sphero.com remix"
    echo ""
    echo "Usage: $0  -f|--file -t|--title --public -u|--username -p|--password -i|--id -r|--robot " 1>&2
    echo ""
    echo " -f | --file         Optional     The javascript file to deploy"
    echo " -t | --title        Optional     Title of the remix"
    echo "      --public       Optional     Make the remix public"
    echo " -u | --username     Required     The email or userid of the edu.sphero.com user"
    echo " -p | --password     Required     The password of the edu.sphero.com user"
    echo " -i | --id           Required     The remix Id to deploy the javascript code to"
    echo " -r | --robot        Optional     Comma seperated list of robots to support"
    echo ""
    exit 1
}
function echoInput() {
    echo "deploy-spheroedu.sh:"
    echo -n "    file........ "
    echoInfo "$code"
    echo -n "    title....... "
    echoInfo "$title"
    echo -n "    public...... "
    echoInfo "$public"
    echo -n "    username.... "
    echoInfo "$email"
    echo -n "    password.... "
    echoInfo "$password"
    echo -n "    id.......... "
    echoInfo "$remix_id"
    echo -n "    robot....... "
    echoInfo "$robot"

}

function parseInput() {
    
    local OPTIONS=f:t:u:p:i:r:
    local LONGOPTS=file:,title:,public,username:,password:,id:,robot:

    # -use ! and PIPESTATUS to get exit code with errexit set
    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out "--options")
    # -pass arguments only via -- "$@" to separate them correctly
    ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        # e.g. return value is 1
        # then getopt has complained about wrong arguments to stdout
        usage
        exit 2
    fi
    # read getopt's output this way to handle the quoting right:
    eval set -- "$PARSED"
    while true; do
        case "$1" in
        -f | --file)
            code=$2
            shift 2
            ;;
        -t | --title)
            title=$2
            shift 2
            ;;
        - | --public)
            public=1
            shift 1
            ;;
        -u | --username)
            email=$2
            shift 2
            ;;
        -p | --password)
            password=$2
            shift 2
            ;;
        -i | --id)
            remix_id=$2
            shift 2
            ;;
        -r | --robot)
            robot=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echoError "Invalid option $1 $2"
            exit 3
            ;;
        esac
    done
}
# input variables 
declare code=code.js
declare title=Hello world
declare public=
declare email=
declare password=
declare remix_id=
declare robot=9

parseInput "$@"

#verify required parameters are set
if [ -z "${email}" ] || [ -z "${password}" ] || [ -z "${remix_id}" ]; then
    echo ""
    echoError "Required parameter missing! "
    echoInput #make it easy to see what is missing
    echo ""
    usage
    exit 2
fi


    # --- BEGIN USER CODE ---
    edusphero_url=https://edu.sphero.com/
if [ $public ]; then
    public=true
else
    public=false
fi

if [ ! -f $code ]; then
    echoError "Cannot find code file $code"
    return 1;
fi



# Create cookie with CSRF token
echoInfo "Initial request to sphero edu"
curl -Ss -e $edusphero_url -c cookie.tmp $edusphero_url > /dev/null

if [ $? -ne 0 ]; then
    echoError "Could not reach sphero edu at $edusphero_url" 
    return 1;
fi

# Get the CSRF token
csrf_token=$( cat cookie.tmp | grep csrftoken | awk '{print $7;}' )

# Login to edusphere
echoInfo "Login to sphero edu with user $email"
curl -Ss -e $edusphero_url -F email=$email -F password=$password -F csrfmiddlewaretoken=$csrf_token -H "x-csrftoken: $csrf_token" -b cookie.tmp -c cookie.tmp ${edusphero_url}account/login > /dev/null

if [ $? -ne 0 ]; then
    echoError "Could not login to sphero edu for user $email"
    return 1;
fi

# Get the user id from cookie
user_id=$( cat cookie.tmp | grep userId | awk '{print $7;}' )
# Get the CSRF token
csrf_token=$( cat cookie.tmp | grep csrftoken | awk '{print $7;}' )

# Patch to script on server
echoInfo "Patch code.lab to remix $remix_id"
cat $code | jq -R -s -c '{"program_type": "text", "identifier": "'$remix_id'", "data": ("12;" + .), "robots": [{"id": 9, "name": "BOLT"}], "name": "'$title'"}' | curl -Ss -e $edusphero_url -F "program=@-;filename=code.lab" -F "title=$title" -F "public=$public" -F "robot[]=$robot" -H "user-id: $user_id" -H "x-csrftoken: $csrf_token" -H "accept: application/json" -b cookie.tmp -c cookie.tmp -X PATCH ${edusphero_url}api/v1/remixes/my/${remix_id}/ > /dev/null

if [ $? -ne 0 ]; then
    echoError "Could patch code.lab to remix $remix_id"
    return 1;
fi

# --- END USER CODE ---
