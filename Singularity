#-*- mode: rpm-spec; fill-column: 79 -*-
Bootstrap: docker
From: debian:wheezy

%environment
SPACK_ROOT=/
LC_ALL=C
export SPACK_ROOT LC_ALL

%post
# Update repo and install dependencies.
deps_runtime="python environment-modules procps"
deps_build_spack="gcc g++ curl make bzip2 patch perl unzip gfortran"
deps_build="wget $deps_runtime $deps_build_spack"
# Don't thrash the Debian server; only install missing packages.
echo $deps_build | tr " " "\n" | sort > .deps_needed
dpkg-query -f '${binary:Package}\n' -W | sort > .deps_installed
missing=$(join -a 1 -v 1 .deps_needed .deps_installed)
rm -f .deps_needed .deps_installed
[ -z "$missing" ] || { apt-get update && apt-get -y install $missing ; }
# pod2man is missing from the perl package, but is needed to compile openssl.
[ -f /usr/bin/pod2man ] || apt-get -y install --reinstall perl

# Install R-3.3.0 from spack because CRAN only goes up to R-3.2.5 for Wheezy.
url=https://github.com/spack/spack/releases/download/v0.11.2/spack-0.11.2.tar.gz
prefix=/
cd $prefix
command -v spack || wget --no-check-certificate $url -O - | tar -xz --strip-components=1
rm -f *.md *.ini LICENSE NOTICE
cd -
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
spack -h > /dev/null		# Creates /opt/spack

# Create a wrapper around spack and environmental modules.
cat <<EOF > /usr/bin/launch
#!/bin/bash
set -e
source /etc/profile.d/modules.sh
source /share/spack/setup-env.sh
spack load r@3.3.0 curl libxml2 pkg-config zlib openssl
exec \$@
EOF
chmod +x /usr/bin/launch

%test
launch R --version

%runscript
launch R $@
