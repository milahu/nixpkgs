#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash coreutils git nix-prefetch-github jq

repourl='https://github.com/frida/frida'

source_json_file='src.json'

# check dependencies
for cmd in git nix-prefetch-github jq; do
  if ! command -v $cmd >/dev/null; then
    echo "error: please install $cmd"
    exit 1
  fi
done

dir="$(readlink -f "$(dirname "$0")")"
cd "$dir"

set -eu
#set -x # trace

old_source_json='{}'
if [ -e "$source_json_file" ]; then
    old_source_json="$(< $source_json_file)"
    echo "old_source_json:"
    echo "$old_source_json"
fi

#contentLength="$(echo "$old_source_json" | jq -r .contentLength)"
#lastModified="$(echo "$old_source_json" | jq -r .lastModified)"

version="$(echo "$old_source_json" | jq -r .version)"
new_source_json="$old_source_json"

echo "fetching version ..."
versionActual=$(git ls-remote --tags https://github.com/frida/frida | sed 's|^.*refs/tags/||' | sort -V | tail -n1)
if [[ "$version" == "$versionActual" ]]; then
    echo "done: source is at latest version $version"
    exit
fi

echo "version changed:"
echo "- $version"
echo "+ $versionActual"
echo
echo "updating $source_json_file to version $versionActual ..."

echo "fetching repo ..."
#git ls-remote --tags $repourl | grep -v '\^{}$' | sed 's|^.*refs/tags/||'
tempdir=$(mktemp -d)
pushd $tempdir
git clone --depth=1 $repourl
cd $(basename $repourl)

echo "fetching submodules ..."
submodule_revs="$(git submodule status)"
submodule_urls="$(git config --file .gitmodules --get-regexp '\.(path|url)$' | awk '{print $2}')"
while read line; do
    rev=${line:1:40}
    path=${line:42}
    # TODO generalize "github"
    old_rev="$(echo "$old_source_json" | jq -r '.paths[$path].github.rev' --arg path "$path")"
    if [[ "$rev" == "$old_rev" ]]; then
        echo "path is already up-to-date: $path"
        continue
    fi
    echo "rev changed for path $path:"
    echo "- $old_rev"
    echo "+ $rev"
    echo "fetching submodule for path $path ..."
    key=$(git config --file .gitmodules --list | grep '\.path='"$path"'$' | cut -d. -f2)
    url=$(git config --file .gitmodules --get submodule.$key.url)
    repo=$(basename $url .git)
    owner=$(basename $(dirname $url))
    # TODO generalize "github"
    prefetch_json="$(nix-prefetch-github --json --rev $rev $owner $repo)"
    # remove default values
    prefetch_json="$(echo "$prefetch_json" | jq 'with_entries(select(.value != false))')"
    echo "prefetch_json:"
    echo "$prefetch_json"
    #debug
    # update sources json
    # TODO generalize "github"
    new_source_json="$(echo "$new_source_json" | jq --sort-keys '. * { "paths": { ($path): { "github": $github } } }' --arg path "$path" --argjson github "$prefetch_json")"
    echo "new_source_json:"
    echo "$new_source_json"
    # write early and often, so we can stop and resume
    echo "$new_source_json" > $source_json_file
done <<< "$submodule_revs"
popd

new_source_json="$(echo "$new_source_json" | jq --sort-keys '.version = $version' --arg version "$versionActual")"
echo "$new_source_json" > $source_json_file

echo "done: updated $source_json_file to version $versionActual"
