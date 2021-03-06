#!/bin/bash

set -e

# change to root of bosh release
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/../..

set -e

version=$(cat ../version/number)
if [ -z "$version" ]; then
  echo "missing version number"
  exit 1
fi
if [[ "${release_name}X" == "X" ]]; then
  echo "missing \$release_name"
  exit 1
fi

cat > ~/.lockpick << EOF
app_id: foobar
user_id: myuserid
key: mykeyid
output_file: ~/mygitcrypt.key
vault_address: "https://127.0.0.1:8200"
EOF

cd ../
mkdir -p $GOPATH/src/github/longnguyen11288/
cp -r lockpick $GOPATH/src/github/longnguyen11288/.
pushd $GOPATH/src/github/longnguyen11288/lockpick

godep restore

echo Prepare github release information
set -x
mkdir -p releases
cp ci/release_notes.md releases/notes.md
echo "${release_name} v${version}" > releases/name
echo "v${version}" > releases/tag

goxc -bc="linux,!arm darwin,amd64" -d=releases -pv=${version}

cp -r releases $DIR/../../.