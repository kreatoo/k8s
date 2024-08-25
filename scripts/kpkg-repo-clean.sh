#!/bin/bash
t=$(mktemp -d)
cd $t


git clone https://github.com/kreatolinux/kpkg-repo.git --depth=1
cd kpkg-repo
PKGFILES=()

for i in */run; do
	PKGNAME="$(dirname "$i")"
	VERSION=$(grep -oP '(?<=VERSION=")[^"]+' "$i" | grep -v '\$(' | grep -v '$VERSION')
	RELEASE=$(grep -oP '(?<=RELEASE=")[^"]+' "$i" | grep -v '\$(' | grep -v '$RELEASE')
	EPOCH=$(grep -oP '(?<=EPOCH=")[^"]+' "$i" | grep -v '\$(' | grep -v '$EPOCH')
	FIN=$PKGNAME-$VERSION
	if [ -n "$RELEASE" ]; then
		FIN=$FIN-$RELEASE
	fi
	if [ -n "$EPOCH" ]; then
		FIN=$FIN-$EPOCH
	fi
	PKGFILES+=($FIN.kpkg)
done

for i in /var/cache/kpkg/archives/system/*/*.kpkg; do
	delete=1
	for pkgfile in ${PKGFILES[@]}; do
		if [ "$(basename $i)" = "$pkgfile" ]; then
			delete=0
		fi
	done
	
	if [ "$delete" = "1" ]; then
		echo "deleting $i"
		rm -f $i
	fi
done

cd - 
rm -rf $t
