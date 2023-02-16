#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

username=$1

echo -e "\e[32m[*] Searching for files with sensitive extensions...\e[0m"

# Search for files with sensitive extensions
sensitive_files=$(find / -type f \( -iname "*.conf" -o -iname "*.cfg" -o -iname "*.ini" -o -iname "*.txt" -o -iname "*.csv" -o -iname "*.log" -o -iname "*.db" -o -iname "*.sql" -o -iname "*.sqlite" -o -iname "*.bak" \) 2>/dev/null)

# Search the sensitive files and print the output in a cool haxory way
echo -e "\n\e[32m[*] Searching the sensitive files for entries matching $username...\e[0m"

while read -r file; do
  # Search for entries matching the pattern "$username [whitespace or separator] text [whitespace]"
  grep -q -E "$username[[:space:]:/][[:print:]]*[[:space:]]" "$file" 2>/dev/null && {
    # Print the path to the file and the number of the line the entry was found in
    echo -e "\e[36m$file\e[0m"
    grep -n -E "$username[[:space:]:/][[:print:]]*[[:space:]]" "$file" 2>/dev/null | while read -r line; do
      line_num=$(echo "$line" | cut -d':' -f1)
      entry=$(echo "$line" | cut -d':' -f2-)
      echo -e "\tLine $line_num: \e[33m$username\e[0m $entry"
    done
    echo
  }
done <<< "$sensitive_files"

# Search for all other files and print the output in a cool haxory way
echo -e "\n\e[32m[*] Searching for all other files...\e[0m"

while read -r file; do
  # Exclude files with sensitive extensions
  ! echo "$file" | grep -q -Ei "\.(conf|cfg|ini|txt|csv|log|db|sql|sqlite|bak)$" && {
    # Search for entries matching the pattern "$username [whitespace or separator] text [whitespace]"
    grep -q -E "$username[[:space:]:/][[:print:]]*[[:space:]]" "$file" 2>/dev/null && {
      # Print the path to the file and the number of the line the entry was found in
      echo -e "\e[36m$file\e[0m"
      grep -n -E "$username[[:space:]:/][[:print:]]*[[:space:]]" "$file" 2>/dev/null | while read -r line; do
        line_num=$(echo "$line" | cut -d':' -f1)
        entry=$(echo "$line" | cut -d':' -f2-)
        echo -e "\tLine $line_num: \e[33m$username\e[0m $entry"
      done
      echo
    }
  }
done < <(find / -type f -print 2>/dev/null)

echo -e "\e[32m

