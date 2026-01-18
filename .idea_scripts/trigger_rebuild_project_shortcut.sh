#!/bin/bash

# Trigger IntelliJ IDEA's "Rebuild Project" shortcut (Command+Shift+0)
echo "Trigger shortcut to rebuild project in IntelliJ IDEA"

osascript <<EOF
tell application "IntelliJ IDEA"
    activate
end tell

delay 1

tell application "System Events"
    tell process "IntelliJ IDEA"
        set frontmost to true
        key code 29 using {command down, shift down}
    end tell
end tell
EOF

echo "Done!"