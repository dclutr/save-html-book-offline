#!/usr/bin/env bash

#
# Copyright 2022 Akshansh Manchanda
#
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public Licenses as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with the program. If not, see
# <https://www.gnu.org/licenses>
#

function parse-links()
{
  echo "height $((--height))"
  for attribute in href src
  do 
    # attribute="value (or) attribute=value
    for match in $( echo "$html" | grep -o -i \
"$attribute=[\"][^\"]*[\"]
$attribute=[\'][^\']*[\']
$attribute=[^\"\'][^> ]*"
    )
    do
      echo "found $match"
      url="$( unquote "$( trim-left "$match" "$(("${#attribute}"+1))" )" )"
      case "$url" in
        "mailto:"*)    continue;; # ignore mailto URL
        "#"*)          continue;; # ignore fragment-only URL
        *"//$DOMAIN")  url="$url/index.html";;
        "//$DOMAIN/"*) url="$( index-if-dir "$url" )";;
        *"//"*)        continue;; # ignore cross domain URL
        "/"*)          url="$( index-if-dir "http://$DOMAIN$url" )";;
        "../"*)        url="$( index-if-dir "$( url-for-outer-dir "$url" "$download_url" )" )";;
        "./"*)         url="$( index-if-dir "$( url-for-same-dir "${url:2}" "$download_url" )" )";;
        *)             url="$( index-if-dir "$( url-for-same-dir "$url" "$download_url" )" )";;
      esac
      if [ ! -z "$url" ]
      then
        local_url="$( slashes-to-dots "$( remove-scheme "$url" )" )"
        swap-html "$match" "$attribute=\"$local_url\""
        push "$height" "$( remove-fragment "$local_url" )" "$( remove-fragment "$url" )"
      fi
    done
  done
}

function get-domain()
{
  local i=0
  for (( ; i<"${#1}"; i++ ))
  do
    if [[ "${1:i:1}" == "/" ]]
    then
      echo "${1:0:i}"
      return
    fi
  done
  echo "$1/"
}

function url-for-outer-dir()
{
  local out=0
  while [[ "${1:((3*out)):3}" == "../" ]]
  do (( out++ ))
  done
  url="${1:((3*out))}"
  local i="${#2}"
  while (( out >= 0 ))
  do
    (( i-- ))
    if [[ "${2:i:1}" == "/" ]]
    then (( out-- ))
    fi
  done
  echo "${2:0:i}/$url"
}

function url-for-same-dir()
{
  local i="${#2}"
  (( i-- ))
  while [[ "${2:i:1}" != "/" ]]
  do (( i-- ))
  done
  echo "${2:0:i}/$1"
}

function push()
{
  if [[ "$1" = -1 ]]
  then
    return
  fi
  if [ -z "$( cat ".history" | grep "$2#" )" ]
  then
    echo "$1" >> ".height-stack"
    echo "$2" >> ".filename-stack"
    echo "$3" >> ".url-stack"
    echo "$2#$1" >> ".history"
    echo "push() $1 $3"
  fi
}

function pop()
{
  # get last line of files
  height="$( tail -n 1 ".height-stack" )"
  download_target="$( tail -n 1 ".filename-stack" )"
  download_url="$( tail -n 1 ".url-stack" )"

  if [ -z "$download_url" ]
  then return -1
  else
    # remove last line from files
    for stack in  ".height-stack" ".filename-stack" ".url-stack"
    do
      echo "$(head -n -1 "$stack")" > "$stack"
    done
    echo ""
    echo "pop() $height $download_url"
  fi
}

function swap-html()
{
  html="${html/"$1"/"$2"}"
  echo "swapping $1 ==> $2"
}

function init-book()
{
  mkdir "$1"
  cd "$1"
  for file in ".height-stack" ".url-stack" ".filename-stack" ".history"
  do echo "" > "$file"
  done
  echo "init-book() $1"
}

function get-title()
{
  local title
  title="$( alnum-words "$( trim "$( echo "$html" | grep "<title>[^<]*</title>" )" 7 8 )" )"
  if [ ! -z "$title" ]
  then
    echo "$title"
    return
  fi
  local line="$( echo "$html" | grep -n "<title" )"
  title="$( alnum-words "$( echo "$html" | head -n "$(("${line/":"*}" + 1))" | tail -n 1 )" )"
  if [ ! -z "$title" ]
  then
    echo "$title"
    return
  fi
  echo "default title"
}


function index-if-dir()
{
  case "$1" in
    *"/") echo "$1index.html";;
    *)    echo "$1";;
  esac
}

function unquote()
{
  case "$1" in
    \"*\") echo "${1:1:-1}";;
    \'*\') echo "${1:1:-1}";;
    *)     echo "$1";;
  esac
}

function remove-scheme()
{
  echo "${1/*"//"}"
}

function remove-fragment()
{
  echo "${1/"#"*}"
}

function slashes-to-dots()
{
  echo "${1//\//\.}"
}

function trim-left()
{
  echo "${1:$2}"
}

function trim()
{
  echo "${1:$2:-$3}"
}

function alnum-words()
{
  echo "${1//[^[:alnum:] ]}"
}



# default height = 1
if [ -z "$2" ]
then height=1
else height="$2"
fi

# first argument url
if [ -z "$1" ]
then
  echo "hb <url> [<height>]"
  echo "url as first argument is mandatory"
else
  DOMAIN="$( get-domain "$( remove-scheme "$1" )" )"
  download_url="$( index-if-dir "$( remove-fragment "$1" )" )"
  html="$( curl "$download_url" )"
  init-book "$( get-title "$html" )"
  parse-links
  for file in "index.html" "$( slashes-to-dots "$( remove-scheme "$download_url" )" )"
  do
    echo "$html" > "$file"
    echo "$download_url#$height" > ".history"
  done
  while pop # pops height download_url download_target
  do   
    case "$download_url" in
    *".html"|*".htm")
      html="$( curl "$download_url" )"
      parse-links
      echo "$html" > "$download_target";;
    *)
      wget "$download_url" -O "$download_target";;
    esac
  done
fi

