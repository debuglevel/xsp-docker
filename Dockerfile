# build and tag me:
# docker build -t debuglevel/xsp:latest . && docker tag debuglevel/xsp:latest debuglevel/xsp:$(date +%Y-%m-%d)

# the image we want to base our image on.
# this is a debian with a patched mono version.
FROM debuglevel/mono:latest

MAINTAINER Marc Kohaupt <debuglevel@gmail.com>

# RUN executes a command in the container.
# for each RUN, docker creates a new layered image on top of the image created by the previous RUN.
# we use one big RUN so that we can delete our temporary files at the end. this way the image remains as small as possible.

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	# install packages needed to compile xsp
		autoconf \
		automake \
		build-essential \
		git \
		gettext \
		libtool \
		pkg-config \
	# install packages needed to run xsp
		ca-certificates \
		sqlite3 \
	&& rm -rf /var/lib/apt/lists/* \
	
	# fetch latest xsp sources (without any history)
	&& cd /local/mono-compile \
	&& git clone -v --progress --depth 1 --single-branch https://github.com/mono/xsp.git \
	&& cd /local/mono-compile/xsp \
	
	# do autogen and configure
	&& ./autogen.sh --prefix=$MONO_PREFIX \
	&& ./configure --prefix=$MONO_PREFIX \

	# make
	&& make \
	
	# install into $MONO_PREFIX
	&& make install \
	
	# remove temporary files
	&& rm -rf /local/mono-compile/xsp \
	
	# remove packages which were used to compile mono but are not needed anymore
	&& apt-get remove -y \
		autoconf \
		automake \
		build-essential \
		git \
		gettext \
		libtool \
		pkg-config \
	&& apt-get autoremove -y \
	&& apt-get clean