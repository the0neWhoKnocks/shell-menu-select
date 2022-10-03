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

All flags and an example are demonstrated via the `--help` command.

### Example
```sh
source ./get-choice.sh
getChoice -h
```
