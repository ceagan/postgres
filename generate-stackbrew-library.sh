#!/bin/bash
set -e

declare -A aliases
aliases=(
	[9.4-2.1]='9-2 9 latest'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/postgres-postgis'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for version in "${versions[@]}"; do
	commit="$(cd "$version" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
	pgFullVersion="$(grep -m1 'ENV PG_VERSION ' "$version/Dockerfile" | cut -d' ' -f3 | cut -d- -f1 | sed 's/~/-/g')"
	pgisFullVersion="$(grep -m1 'ENV PGIS_VERSION ' "$version/Dockerfile" | cut -d' ' -f3 | cut -d+ -f1 | sed 's/~/-/g')"
	versionAliases=( $pgFullVersion-$pgisFullVersion $version ${aliases[$version]} )
	
	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
done
