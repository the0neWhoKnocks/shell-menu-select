#!/bin/bash

CHAR__GREEN='\033[0;32m'
CHAR__RESET='\033[0m'
menuStr=""

function hideCursor(){
  printf "\033[?25l"
  
  trap "showCursor && return 0" 2                     # capture CTRL+C so cursor can be reset
}

function showCursor(){
  printf "\033[?25h"
}

function clearLastMenu(){
  local msgLineCount=$(printf "$menuStr" | wc -l)
  echo -en "\033[${msgLineCount}A"                    # moves the cursor up N lines so the output overwrites it

  [ $1 ] && tput ed                                   # clear to end of screen to ensure there's no text left behind from previous input
}

function renderMenu(){
  local start=0
  local selector=""
  local instruction="$1"
  local selectedIndex=$2
  local listLength=$itemsLength
  local longest=0
  local spaces=""
  menuStr="\n $instruction\n"

  for (( i=0; i<$itemsLength; i++ )); do              # Get the longest item from the list so that we know how many spaces to add
    if (( ${#menuItems[i]} > longest )); then         # to ensure there's no overlap from longer items when a list is scrolling up or down.
      longest=${#menuItems[i]}
    fi
  done
  spaces=$(printf ' %.0s' $(eval "echo {1.."$(($longest))"}"))

  if [ $3 -ne 0 ]; then
    listLength=$3

    if [ $selectedIndex -ge $listLength ]; then
      start=$(($selectedIndex+1-$listLength))
      listLength=$(($selectedIndex+1))
    fi
  fi

  for (( i=$start; i<$listLength; i++ )); do
    local currItem="${menuItems[i]}"
    currItemLength=${#currItem}

    if [[ $i = $selectedIndex ]]; then
      selector="${CHAR__GREEN}ᐅ${CHAR__RESET}"
      currItem="${CHAR__GREEN}${currItem}${CHAR__RESET}"
    else
      selector=" "
    fi

    currItem="${spaces:0:0}${currItem}${spaces:currItemLength}"

    menuStr="${menuStr}\n ${selector} ${currItem}"
  done

  menuStr="${menuStr}\n"

  [ $4 ] && clearLastMenu                             # whether or not to overwrite the previous menu output

  printf "${menuStr}"
}

function getChoice(){
  local KEY__ARROW_UP=$(echo -e "\033[A")
  local KEY__ARROW_DOWN=$(echo -e "\033[B")
  local KEY__ENTER=$(echo -e "\n")
  local captureInput=true
  local displayHelp=false
  local maxViewable=0
  local instruction="Select an item from the list:"
  local selectedIndex=0
  local -n outVar=selectedChoice

  remainingArgs=()
  
  if [[ $# -lt 1 ]]; then
    echo "[ERROR] No arguments specified."            # If there is only the getChoice command, show error and help.
    displayHelp=true
  fi
  
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      -h|--help)
        displayHelp=true
        shift
        ;;
      -i|--index)
        selectedIndex=$2
        shift 2
        ;;
      -m|--max)
        maxViewable=$2
        shift 2
        ;;
      -o|--options)
        menuItems=$2[@]
        menuItems=("${!menuItems}")
        shift 2
        ;;
      -q|--query)
        instruction="$2"
        shift 2
        ;;
      -O|--output)
        local -n outVar=$2
        shift 2
        ;;
      *)
        remainingArgs+=("$1")
        shift
        ;;
    esac
  done

  # just display help
  if $displayHelp; then
    echo;
    echo "Usage: getChoice [OPTION]..."
    echo "Renders a keyboard navigable menu with a visual indicator of what's selected."
    echo;
    echo "  -h, --help     Displays this message"
    echo;
    echo "  -i, --index    The initially selected index for the options   [Default: 0]"
    echo "  -m, --max      Limit how many options are displayed"
    echo "  -o, --options  An Array of options for a user to choose from"
    echo "  -O, --output   Name of variable to store choice               [Default: \$selectedChoice]"
    echo "  -q, --query    Question or statement presented to the user    [Default: \"Select an item from the following list:\""
    echo;
    echo "Examples:"
    echo "  # Define options"
    echo "  foodOptions=(\"pizza\" \"burgers\" \"chinese\" \"sushi\" \"thai\" \"italian\" \"other\")"
    echo;
    echo "  # Get input from user"
    echo "  getChoice -q \"What do you feel like eating?\" -o foodOptions -i 0 -m \$((\${#foodOptions[@]}-1))"
    echo;
    echo "  # Display choice made by user"
    echo "  echo \" Your choice is '\${selectedChoice}'\""
    echo;
    echo "---------------------------------------------------------------------------------"
    echo;
    echo "  # Define options"
    echo "  emotionOptions=(\"Happy\" \"Sad\" \"Confused\" \"Neutral\" \"Stressed\" \"Angry\")"
    echo;
    echo "  # Get input from user and store choice in \$emotion"
    echo "  getChoice -q \"How are you feeling today?\" -o emotionOptions -i 0 -m \$((\${#emotionOptions[@]}-1)) -O emotion"
    echo;
    echo "  # Ask why the user is feeling the emotion they chose"
    echo "  echo \"Why are you feeling \${emotion}?\""
    echo;
    return 0
  fi

  set -- "${remainingArgs[@]}"
  local itemsLength=${#menuItems[@]}

  renderMenu "$instruction" $selectedIndex $maxViewable
  hideCursor

  while $captureInput; do
    read -rsn3 key # `3` captures the escape (\033'), bracket ([), & type (A) characters.

    case "$key" in
      "$KEY__ARROW_UP")
        selectedIndex=$((selectedIndex-1))
        (( $selectedIndex < 0 )) && selectedIndex=$((itemsLength-1))

        renderMenu "$instruction" $selectedIndex $maxViewable true
        ;;

      "$KEY__ARROW_DOWN")
        selectedIndex=$((selectedIndex+1))
        (( $selectedIndex == $itemsLength )) && selectedIndex=0

        renderMenu "$instruction" $selectedIndex $maxViewable true
        ;;

      "$KEY__ENTER")
        clearLastMenu true
        showCursor
        captureInput=false
        ;;
    esac
  done
  outVar="${menuItems[$selectedIndex]}"                 # Store output in $selectedChoice or variable defined in --output value
  return 0
}
