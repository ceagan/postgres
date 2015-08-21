#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

packagesUrl='http://apt.postgresql.org/pub/repos/apt/dists/jessie-pgdg/main/binary-amd64/Packages'
packages="$(echo "$packagesUrl" | sed -r 's/[^a-zA-Z.-]+/-/g')"
curl -sSL "${packagesUrl}.bz2" | bunzip2 > "$packages"

for version in "${versions[@]}"; do
	splitPos=$(expr index "$version" '-')
	pgVersion=${version:0:$(($splitPos - 1))}
	pgFullVersion="$(grep -m1 -A10 "^Package: postgresql-$pgVersion\$" "$packages" | grep -m1 '^Version: ' | cut -d' ' -f2)"
	pgisVersion=${version:$splitPos}
	pgisFullVersion="$(grep -m1 -A10 "^Package: postgresql-$pgVersion-postgis-$pgisVersion\$" "$packages" | grep -m1 '^Version: ' | cut -d' ' -f2)"
	(
		set -x
		cp docker-entrypoint.sh Dockerfile.template "$version/"
		mv "$version/Dockerfile.template" "$version/Dockerfile"
		sed -i 's/%%PG_MAJOR%%/'$pgVersion'/g; s/%%PG_VERSION%%/'$pgFullVersion'/g' "$version/Dockerfile"
		sed -i 's/%%PGIS_MAJOR%%/'$pgisVersion'/g; s/%%PGIS_VERSION%%/'$pgisFullVersion'/g' "$version/Dockerfile"
	)
done

rm "$packages"
