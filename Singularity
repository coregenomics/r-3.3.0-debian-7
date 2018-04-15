#-*- mode: rpm-spec; fill-column: 79 -*-
Bootstrap: debootstrap
OSVersion: wheezy
MirrorURL: http://ftp.us.debian.org/debian/

%environment
SPACK_ROOT=/usr/local
LC_ALL=C
export SPACK_ROOT LC_ALL

%post
# Update ca-certificates from wheezy-security repo, otherwise spack fails to
# fetch xz with:
# curl: (60) SSL certificate problem: unable to get local issuer certificate
repo=/etc/apt/sources.list.d/security.list
[ -f "repo" ] || cat <<EOF > $repo
deb http://security.debian.org/debian-security/ wheezy/updates main
deb http://deb.debian.org/debian/ wheezy-updates main
EOF
# Install OS packages.  Skip time consuming apt-get commands if all packages
# are present.
deps_runtime_spack="python environment-modules"
deps_build_spack="gcc g++ gfortran curl make bzip2 patch perl unzip"
deps_build="wget $deps_runtime_spack $deps_build_spack"
echo $deps_build | tr " " "\n" | sort > .deps_needed
dpkg-query -f '${binary:Package}\n' -W | sort > .deps_installed
missing=$(join -a 1 -v 1 .deps_needed .deps_installed)
rm -f .deps_needed .deps_installed
[ -z "$missing" ] || { apt-get update && apt-get -y install $missing ; }

# Install R-3.3.0 from spack because CRAN only goes up to R-3.2.5 for Wheezy.
url=https://github.com/spack/spack/releases/download/v0.11.2/spack-0.11.2.tar.gz
prefix=/usr
cd $prefix
command -v spack || wget --no-check-certificate $url -O - | tar -xz --strip-components=1
rm -f *.md *.ini LICENSE NOTICE
cd -
spack -h > /dev/null		# Creates /usr/local/opt/spack
# Spack creates a config file after discovering compilers, but caches the
# results which makes it difficult to add on c++, fortran, etc once a compiler
# version is found.  Therefore remove the cached compiler first to always
# auto-detect compilers.
compiler=gcc@4.7
spack compiler rm $compiler || true
spack compiler find		# Detect compiler.
spack compiler info $compiler
# Install older version of openssl because building openssl@1.0.2k fails with:
# make[1]: *** No rule to make target `../include/openssl/bio.h', needed by `cryptlib.o'.  Stop.
spack install openssl@1.0.2j
export FORCE_UNSAFE_CONFIGURE=1 # Workaround for compiling "tar" as root.
spack install r@3.3.0

# Create a wrapper around spack and environmental modules.
cat <<EOF > /usr/bin/launch
#!/bin/bash
set -e
source /etc/profile.d/modules.sh
source /usr/share/spack/setup-env.sh
spack load r@3.3.0 curl libxml2 pkg-config zlib openssl
exec \$@
EOF
chmod +x /usr/bin/launch

%test
launch R --version

%runscript
launch R $@
