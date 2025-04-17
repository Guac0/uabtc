#!/bin/sh

# Define 5 ASCII art pieces
art1='
 /\_/\  
( o.o ) 
 > ^ <  
'

art2='
   __
  /  \__
 (    @\___
 /         O
/   (_____/
/_____/ U
'

art3='
  ,__,
  (oo)____
  (__)    )\\
     ||--|| *
'

# https://www.asciiart.eu/animals/bats
# jgs
art4='
 /\                 /\
/ \`._   (\_/)   _.`/ \
|.``._`--(o.o)--`_.``.|
 \_ / `;=/ " \=;` \ _/
   `\__| \___/ |__/`
        \(_|_)/
         " ` "
'

# https://www.asciiart.eu/animals/frogs
# Hayley Jane Wakenshaw
art5='
       _e-e_
     _(-._.-)_
  .-(  `---`  )-.
 __\ \\\___/// /__
`-._.`/M\ /M\`._,-
'

# Array of ASCII art
arts="$art1
$art2
$art3
$art4
$art5"

# Pick a random number 1-5
index=$(( (RANDOM % 5) + 1 ))

# Display the selected ASCII art
i=1
for art in "$art1" "$art2" "$art3" "$art4" "$art5"; do
  if [ "$i" -eq "$index" ]; then
    echo "$art"
    break
  fi
  i=$((i + 1))
done

# Print 5 animal names
echo "Please prove that you are not a robot before you can access this program."
echo "What is the animal displayed above?"
echo ""
echo "1. Cat"
echo "2. Dog"
echo "3. Cow"
echo "4. Bat"
echo "5. Frog"

# Ask for input
echo -n "Enter a number (1-5): "
read input

# If input is "5", launch bash
if [ "$input" = "$index" ]; then
  echo "Launching Bash shell..."
  exec /bin/bash
else
  echo -n "You're either a robot, or you have really bad eyesight." # Wait to acknowledge
fi
