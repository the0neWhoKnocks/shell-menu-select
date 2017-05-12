#!/bin/bash
 
menuChoice=""

function renderMenuText(){
  local instruction="$1"
  local menuItems=$2[@]
  local menuItems=("${!menuItems}")
  local selectedIndex=$3
  local reRender=$4
  local listLength=${#menuItems[@]}
  local itemsStr=""
  local start=0
  
  if [ $5 -ne 0 ]; then
    local listLength=$5
    
    if [ $selectedIndex -ge $listLength ]; then
      local start=$(($selectedIndex+1-$listLength))
      local listLength=$(($selectedIndex+1)) 
    fi
  fi
  
  for (( i=$start; i<$listLength; i++ )); do
    # ● ○ █ ■ ☛ ✔ ➔ ➜ ➤
    [[ $i = $selectedIndex ]] && local selector="■" || local selector=" "
    local itemsStr="$itemsStr\n $selector ${menuItems[i]}"
  done
  
  local msg=""
  local msg="${msg}${instruction}\n"
  local msg="${msg}${itemsStr}\n"
  
  if [[ "$reRender" == "true" ]]; then
    local msgLineCount=$(printf "$msg" | wc -l)
    tput cuu $msgLineCount && echo -ne "\r" && tput ed
  fi
  
  printf "$msg"
}

function displayMenu(){
  local instruction=${1:-"Select an item from the list:"}
  local menuItems=$2[@]
  local menuItems=("${!menuItems}")
  # use the second arg, or set default to zero
  local selectedIndex=${3:-0}
  local maxViewable=${4:-0}
  local itemsLength="$(echo ${#menuItems[@]})"
  local readSpeed=0.1
  
  renderMenuText "$instruction" $2 $selectedIndex false $maxViewable
  
  while read -rsn1 ui; do
    case "$ui" in
    $'\x1b')    # Handle ESC sequence.
      # Flush read. We account for sequences for Fx keys as
      # well. 6 should suffice far more then enough.
      read -rsn1 -t $readSpeed tmp
      if [[ "$tmp" == "[" ]]; then
        read -rsn1 -t $readSpeed tmp
        case "$tmp" in
        "A")
          let selectedIndex=${selectedIndex}-1
          
          if [ $selectedIndex -lt 0 ]; then
            let selectedIndex=$itemsLength-1
          fi
          
          renderMenuText "$instruction" $2 $selectedIndex true $maxViewable
          ;;
        "B") 
          let selectedIndex=${selectedIndex}+1
          
          if [ $selectedIndex -eq $itemsLength ]; then
            let selectedIndex=0
          fi
          
          renderMenuText "$instruction" $2 $selectedIndex true $maxViewable
          ;;
        "C") 
          #printf "Right\n"
          ;;
        "D") 
          #printf "Left\n"
          ;;
        esac
      fi
      # Flush "stdin" with 0.1  sec timeout.
      read -rsn5 -t $readSpeed
      ;;
    # Other one byte (char) cases. Here only quit.
    "") 
      menuChoice=$(echo "${menuItems[$selectedIndex]}")
      break;
      ;;
    q) 
      break
      ;;
    esac
  done
}

foodOptions=("pizza" "burgers" "chinese" "sushi" "thai" "italian")
displayMenu "What do you feel like eating?" foodOptions $((${#foodOptions[@]}-1)) 4
#displayMenu "What do you feel like eating?" foodOptions $((${#foodOptions[@]}-1))
 
printf "\n\nYou chose: $menuChoice  "
