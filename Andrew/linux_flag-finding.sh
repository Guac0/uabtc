# Linux
# https://stackoverflow.com/questions/6844785/how-to-use-regex-with-find-command
# Note that you need to specify .*/ in the beginning because find matches the whole path.
# allows any preceding and following chars, and no numbers
find . -regextype sed -regex ".*[A-Za-z]+-[A-Za-z]+-[A-Za-z]+$"

