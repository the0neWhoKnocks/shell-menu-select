# shell-menu-select

A script that allows a user to use arrow keys to select an item from a list. Sometimes using `select` can be a bit clunky because the user doesn't get any visual feedback about what they're selecting unless a confirmation message is displayed (which adds more overhead).

---

## Usage

```sh
source ./get-choice.sh                                                                                       # Loading from local disk
source <(wget -qO- https://raw.githubusercontent.com/the0neWhoKnocks/shell-menu-select/master/get-choice.sh) # Loading from GitHub at runtime (Good for single script applications)
source <(curl -s https://raw.githubusercontent.com/the0neWhoKnocks/shell-menu-select/master/get-choice.sh)   # Same as above, but with curl instead.
```

---

## Flags
```
-h, --help     Displays help message

-i, --index    The initially selected index for the options   [Default: 0]
-m, --max      Limit how many options are displayed           [Default: Length of options array value]
-o, --options  An Array of options for a user to choose from
-O, --output   Name of variable to store choice               [Default: $selectedChoice]
-q, --query    Question or statement presented to the user    [Default: "Select an item from the following list:"]
```

### Examples
```sh
# Define options
foodOptions=("pizza" "burgers" "chinese" "sushi" "thai" "italian" "other")

# Get input from user
getChoice -q "What do you feel like eating?" -o foodOptions -i 0 -m 6

# Display choice made by user
echo " Your choice is '${selectedChoice}'"
```
---
```sh
# Define options
emotionOptions=("Happy" "Sad" "Confused" "Neutral" "Stressed" "Angry")

# Get input from user and store choice in $emotion
getChoice -q "How are you feeling today?" -o emotionOptions -i 0 -O emotion

# Ask why the user is feeling the emotion they chose
echo "Why are you feeling ${emotion}?"
```
