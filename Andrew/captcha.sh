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

#https://www.asciiart.eu/animals/deer
art6='
\|/    \|/
  \    /
   \_/  ___   ___
   o o-`   ```   `
    O -.         |\
        | |```| |
         ||   | |
         ||    ||
         "     "
'

# https://www.asciiart.eu/animals/camels
# Morfina
art7='
 _______\\__
(_. _ ._  _/ 
 `-` \__. /
      /  / 
     /  /    .--.  .--.
    (  (    / `` \/ `` \   |
     \  \_.`            \   )
     ||               _  `./
      |\   \     ___.`\  /
        `-./   .`    \ |/ 
           \| /       )|\
            |/       // \\ 
            |\    __//   \\__
           //\\  /__/     \__|
       .--_/  \_--.
      /__/      \__\
'

# https://www.asciiart.eu/animals/bisons
# cp97
art8='
((_,...,_))    
   |o o|
   \   /
    ^_^   
'

# https://www.asciiart.eu/animals/aardvarks
art9='
       _.---._    /\\
    ./`      "--`\//
  ./              o \          .-----.
 /./\  )______   \__ \        ( help! )
./  / /\ \   | \ \  \ \       /`-----`
   / /  \ \  | |\ \  \7--- ooo ooo ooo ooo ooo ooo
'

# https://www.asciiart.eu/animals/elephants
# Shanaka Dias
art10='
    _    _
   /=\""/=\
  (=(0_0 |=)__
   \_\ _/_/   )
     /_/   _  /\
   |/ |\ || |
'

# Array of ASCII art
arts="$art1
$art2
$art3
$art4
$art5
$art6
$art7
$art8
$art9
$art10"

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
echo "6. Deer"
echo "7. Camel"
echo "8. Bison"
echo "9. Aardvark"
echo "10. Elephant"

# Ask for input
echo -n "Enter a number (1-10): "
read input

# If input is "5", launch bash
if [ "$input" = "$index" ]; then
  echo "You're a human!"
  exec /bin/bash
else
  echo -n "You're either a robot, or you have really bad eyesight." # Wait to acknowledge
fi
