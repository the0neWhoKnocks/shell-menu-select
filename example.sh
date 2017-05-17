#!/bin/bash
 
source ./menu-select.sh

foodOptions=("pizza" "burgers" "chinese" "sushi" "thai" "italian" "shit")

selectionMenu "What do you feel like eating?" foodOptions $((${#foodOptions[@]}-1)) 4
printf "\n First choice is '${selectedItem}'\n"

selectionMenu "Select another option in case the first isn't available" foodOptions
printf "\n Second choice is '${selectedItem}'\n"
