#!/bin/bash -e

# Increment a version string using Semantic Versioning (SemVer) terminology.
# Parse command line options.

while getopts ":Mmp" Option
do
  case $Option in
    M ) major=true;;
    m ) minor=true;;
    p ) patch=true;;
  esac
done

shift $(($OPTIND - 1))

version=`git tag --sort='-v:refname' | grep [0-9]*.[0-9]*.[0-9]* | head -n 1`

if [ -z $version ]
then
  echo "Adding initial version tag of 1.0.0"
  git tag -a "1.0.0" -m "Version added by CircleCI"

  version="1.0.0"
fi

# Build array from version string.
a=( ${version//./ } )

# If version string is missing or has the wrong number of members, show usage message.

if [ ${#a[@]} -ne 3 ]
then
  echo "Invalid version detected: '$version'"
  echo "usage: $(basename $0) [-Mmp]"
  exit 1
fi
# Increment version numbers as requested.

if [ ! -z $major ]
then
  a[0]=$((${a[0]} + 1 ))
  a[1]=0
  a[2]=0
fi

if [ ! -z $minor ]
then
  a[1]=$((${a[1]} + 1 ))
  a[2]=0
fi

if [ ! -z $patch ]
then
  a[2]=$((${a[2]} + 1 ))
fi

next_version="${a[0]}.${a[1]}.${a[2]}"
git tag -a "$next_version" -m "Version added by CircleCI"
git push -u origin $next_version
echo "$next_version"
