#!/usr/bin/env bash
set -e
launched=0

get_script_path () {
  SOURCE=${BASH_SOURCE[0]}
  while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  printf "%s" "$DIR"
}

path=$( get_script_path )
cd -- "$path"

if [[ ! -d "darkorange-pyside-stylesheet" ]]; then
  git submodule update
fi

for i in *.appimage.extracted; do
  appimage_extracted=$i
done

for i in *.appimage; do
  appimage=$i
done

# digikam seems to be coredumping sadly
ulimit -S -c 0 2> /dev/null

if [[ -n "$appimage_extracted" ]]; then
  launched=1
  "$path/$appimage_extracted/AppRun" "$@" -stylesheet "$path/darkorange-pyside-stylesheet/darkorange/darkorange.qss"
elif [[ -n "$appimage" ]]; then
  launched=1
  "$path/$appimage" -stylesheet "$path/darkorange-pyside-stylesheet/darkorange/darkorange.qss" "$@"
fi

if [[ "$launched" != "1" ]]; then
  echo "Missing appimage into repo directory $path"
fi
  
