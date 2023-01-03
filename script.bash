#!/bin/bash
OIFS="$IFS"
IFS=$'\n'

# get the command line arguments
# $1 is the path to the source directory
# $2 is the path to the destination directory
# $3 is the prefix to add to the url
# $4 is the character to replace the spaces with

# echo help if the first argument is -h or --help
if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
  # explain what the script does
  echo "This script will create a sitemap.xml file from the markdown files in the source directory"

  # echo next line
  echo ""

  # explain what args the script needs to run
  echo "The script needs two arguments and an optional argument"
  echo "The first argument is the path to the source directory"
  echo "The second argument is the path to the destination directory"
  echo "The third argument is the prefix to add to the url"
  echo "The fourth argument is optional and is the character to replace the spaces with in the url"

  exit 1
fi

# echo help if the number of arguments is not 2
if [ $# -lt 2 ] ; then
  echo "Usage: bash $0 <source_path> <destination_path> <prefix_url> [replace_with]"
  exit 1
fi

# get the path to the source directory from the command line
source_path=$1
destination_path=$2
link_prefix=$3
replace_with=${4:-_}

# find all the files in the blogs directory
markdown_files=$(find "$source_path" -type f -regex ".*[0-9A-Za-z] *\.md")


first_line='<?xml version="1.0" encoding="UTF-8"?>'
second_line='<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
last_line='</urlset>'

# replace the sitemap.xml file with the first and second line
echo $first_line > $destination_path
echo $second_line >> $destination_path

counter=0

for file in $markdown_files ; do
  # check if the file is valid
  if [ ! -f $file ] ; then
    # continue
    echo "File $file is not valid"
    continue
  fi

  # counter++
  counter=$((counter+1))
  
  # get the file name without the extension and replace the spaces with _
  file_name=$(basename $file | cut -d '.' -f 1 | tr ' ' $replace_with)

  link="<loc>$link_prefix/$file_name/</loc>"

  # get the date from the file which is written after lastModified: 
  date=$(grep -oP '(?<=lastModified: ).*' $file | head -1)

  # 2022-12-06T06:04:36.643Z -> 2022-12-06 and remove the double quotes
  lastmod=$(echo $date | cut -d 'T' -f 1 | tr -d '"')

  url='  <url>
    '$link'
    <lastmod>'$lastmod'</lastmod>
  </url>'

  if [ -z "$lastmod" ]; then
    url=$(echo "$url" | sed '/<lastmod>.*<\/lastmod>/d')
  fi

  printf '%s\n' "$url" >> $destination_path
done

echo $last_line >> $destination_path

echo "Added $counter files to the sitemap"

IFS="$OIFS"