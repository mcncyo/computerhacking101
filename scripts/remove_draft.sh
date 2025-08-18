#!/bin/bash

# Find all _index.md files in the git tutorials directory and remove the draft: true line
find /home/mcncyo/Desktop/website_code/computerhacking101/content/tutorials/git -name "_index.md" -type f -exec sed -i '/^draft:\s*true\s*$/d' {} \;

echo "Draft status removed from all Git tutorial files."
