# shell-menu-select

A script that allows a user to use arrow keys to select an item from a list. Sometimes using `select` can be a bit clunky because the user doesn't get any visual feedback about what they're selecting unless a confirmation message is displayed (which adds more overhead).

---

## How to load

Typical (you have the script locally)
```sh
source ./get-choice.sh
```

Remote (you want the functionality, but don't want to clone or copy anything)
```sh
source <(wget -qO- https://raw.githubusercontent.com/the0neWhoKnocks/shell-menu-select/master/get-choice.sh)
# or
source <(curl -s https://raw.githubusercontent.com/the0neWhoKnocks/shell-menu-select/master/get-choice.sh)
```

---

## How to use

All flags and an example are demonstrated via the `--help` command.

```sh
source ./get-choice.sh
getChoice -h
```
