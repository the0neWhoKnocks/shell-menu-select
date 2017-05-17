#!/bin/bash
 
ESCAPE_CHAR=$'\033'
menuStr=""

function hideCursor(){
  printf "$ESCAPE_CHAR[?25l"
  
  # capture CTRL+C so cursor can be reset
  trap "showCursor && exit 0" 2
}

function showCursor(){
  printf "$ESCAPE_CHAR[?25h"
}

function clearLastMenu(){
  local msgLineCount=$(printf "$menuStr" | wc -l)
  # moves the curser up N lines so the output overwrites it
  echo -en "$ESCAPE_CHAR[${msgLineCount}A"
  
  # clear to end of screen to ensure there's no text left behind from previous input
  [ $1 ] && tput ed
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
  
  # Get the longest item from the list so that we know how many spaces to add
  # to ensure there's no overlap from longer items when a list is scrolling up or down.
  for (( i=0; i<$itemsLength; i++ )); do
    if (( ${#menuItems[i]} > longest )); then
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
    
    if [[ $i = $selectedIndex ]]; then 
      selector="●"
      selectedItem="$currItem"
    else 
      selector="○"
    fi
    
    currItemLength=${#currItem}
    currItem="${spaces:0:0}${currItem}${spaces:currItemLength}"
    
    menuStr="$menuStr\n $selector ${currItem}"
  done
  
  menuStr="$menuStr\n"
  
  # whether or not to overwrite the previous menu output
  [ $4 ] && clearLastMenu
  
  printf "$menuStr"
}

function selectionMenu(){
  local KEY_ARROW_UP=$(echo -e "$ESCAPE_CHAR[A")
  local KEY_ARROW_DOWN=$(echo -e "$ESCAPE_CHAR[B")
  local KEY_ENTER=$(echo -e "\n")
  local captureInput=true
  local instruction=${1:-"Select an item from the list:"}
  local menuItems=$2[@]
        menuItems=("${!menuItems}")
  local itemsLength=${#menuItems[@]}
  local selectedIndex=${3:-0}
  local maxViewable=${4:-0}
  
  # no menu items, at least 1 required
  if [[ $itemsLength -lt 1 ]]; then
    printf "No menu items provided"
    exit 1
  fi
  
  renderMenu "$instruction" $selectedIndex $maxViewable
  hideCursor

  while $captureInput; do
    
    read -rsn3 key # `3` captures the escape (\033'), bracket ([), & type (A) characters.

    case "$key" in
      "$KEY_ARROW_UP")
        selectedIndex=$((selectedIndex-1))
        (( $selectedIndex < 0 )) && selectedIndex=$((itemsLength-1))
        
        renderMenu "$instruction" $selectedIndex $maxViewable true
        ;;

      "$KEY_ARROW_DOWN")
        selectedIndex=$((selectedIndex+1))
        (( $selectedIndex == $itemsLength )) && selectedIndex=0
        
        renderMenu "$instruction" $selectedIndex $maxViewable true
        ;;

      "$KEY_ENTER")
        clearLastMenu true
        showCursor
        captureInput=false
        ;;
    esac
  done
}
