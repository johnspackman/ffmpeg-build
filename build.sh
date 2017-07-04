 REQUIREMENTS
#
# Git 2.x (install from source)
#
# wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/linux/nasm-2.13.01-0.fc24.x86_64.rpm && yum localinstall -y nasm-2.13.01-0.fc24.x86_64.rpm
#
#

export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/local/lib/pkgconfig

mkdir source
cd source

function doWget {
  BASE=$1
  FILE=$2
  DIR=$3
  if [ ! -f $FILE ] ; then
    rm -rf $DIR
    wget $BASE/$FILE
    if [ $? != 0 ] ; then
      echo "Failed to download $BASE/$FILE"
      exit
    fi
  fi
  if [ ! -d $DIR ] ; then
    tar zxf $FILE
    if [ ! -d $DIR ] ; then
      echo cannot find directory $DIR
      exit
    fi
  fi
  cd $DIR
}

function doWgetBz2 {
  BASE=$1
  FILE=$2
  DIR=$3
  if [ ! -f $FILE ] ; then
    rm -rf $DIR
    wget $BASE/$FILE
    if [ $? != 0 ] ; then
      echo "Failed to download $BASE/$FILE"
      exit
    fi
  fi
  if [ ! -d $DIR ] ; then
    bunzip2 < $FILE | tar xf -
    if [ ! -d $DIR ] ; then
      echo cannot find directory $DIR
      exit
    fi
  fi
  cd $DIR
}

function doWgetConfigure {
  echo
  echo "$1/$2 $3"
  doWget $1 $2 $3
  shift 3
  if [ ! -f config.log ] ; then
    echo Running ./configure "$@"
    ./configure "$@" || exit
  fi
  make -s || exit
  sudo make -s install || exit
  cd ..
}


function make_yasm {
  VER=1.2.0
  echo
  echo "Building yasm-$VER..."
  doWgetConfigure \
    http://www.tortall.net/projects/yasm/releases \
    yasm-$VER.tar.gz \
    yasm-$VER
}


function make_x264 {
  echo
  echo "Building X264...."
  if [ ! -d x264 ] ; then
    git clone git://git.videolan.org/x264
    cd x264
  else
    cd x264
    git pull
  fi
  if [ ! -f config.log ] ; then
    ./configure --enable-static --disable-opencl || exit
  fi
  make -s || exit
  sudo make -s install || exit
  sudo make -s install-lib-static || exit
  cd ..
}


function make_lame {
  VER=3.99.5
  echo
  echo "Building lame-$VER..."
  doWgetConfigure \
    http://downloads.sourceforge.net/project/lame/lame/3.99 \
    lame-$VER.tar.gz \
    lame-$VER \
     --disable-shared --enable-nasm
}


function make_libogg {
  VER=1.3.1
  echo
  echo "Building libogg-$VER..."
  doWgetConfigure \
    http://downloads.xiph.org/releases/ogg \
    libogg-$VER.tar.gz \
    libogg-$VER \
    --disable-shared
}
  

function make_libtheora {
  VER=1.1.1
  echo
  echo "Building libtheora-$VER..."
  doWgetConfigure \
    http://downloads.xiph.org/releases/theora \
    libtheora-$VER.tar.gz \
    libtheora-$VER \
    --disable-shared
}


function make_libvorbis {
  VER=1.3.3
  echo
  echo "Building libvorbis-$VER..."
  doWgetConfigure \
    http://downloads.xiph.org/releases/vorbis \
    libvorbis-$VER.tar.gz \
    libvorbis-$VER \
    --disable-shared
}


function make_voaacenc {
  VER=0.1.2
  echo
  echo "Building vo-aacenc-$VER..."
  doWgetConfigure \
    http://downloads.sourceforge.net/opencore-amr \
    vo-aacenc-$VER.tar.gz \
    vo-aacenc-$VER \
    --disable-shared
}


function make_libvpx {
  echo
  echo "Building libvpx..."
  if [ ! -d libvpx ] ; then
    git clone https://chromium.googlesource.com/chromium/deps/libvpx
    cd libvpx
    ./generate_gypi.sh
    ./update_libvpx.sh
    cd source/libvpx
  else
    cd libvpx/source/libvpx
    git pull
  fi
  if [ ! -f config.log ] ; then
    ./configure || exit
  fi
  make -s || exit
  sudo make -s install || exit
  cd ../../..
}


function make_zlib {
  VER=1.2.11
  echo
  echo "Building zlib-$VER..."
  doWget \
    http://zlib.net \
    zlib-$VER.tar.gz \
    zlib-$VER
  if [ ! -f configure.log ] ; then
    ./configure || exit
  fi
  make -s || exit
  sudo make -s install || exit
  cd ..
}


function make_xvidcore {
  VER=1.3.2
  echo
  echo "Building xvidcore-$VER..."
  doWgetConfigure http://ftp.br.debian.org/debian-multimedia/pool/main/x/xvidcore \
    xvidcore_$VER.orig.tar.gz \
    xvidcore-$VER/build/generic
  cd ../..
}

function make_a52dec {
  VER=0.7.4
  echo
  echo "Building a52dec-$VER..."
  doWgetConfigure http://liba52.sourceforge.net/files \
    a52dec-$VER.tar.gz \
    a52dec-$VER \
    --enable-shared=PKGS
}

function make_faad2 {
  VER=2.7
  echo
  echo "Building faad2-$VER..."
  doWget http://downloads.sourceforge.net/faac \
    faad2-$VER.tar.gz \
    faad2-$VER
  if [ ! -f config.log ] ; then
    autoreconf -vif
    ./configure || exit
  fi
  make -s || exit
  sudo make -s install || exit
  cd ..
}

function make_faac { 
  VER=1.28
  echo
  echo "Building faac-$VER..."
  doWget http://downloads.sourceforge.net/faac \
    faac-$VER.tar.gz \
    faac-$VER
  if [ ! -f config.log ] ; then
    ./bootstrap
    ./configure || exit
  fi
  make -s || exit
  sudo make -s install || exit
  cd ..
}

function make_libraw1394 {
  VER=2.0.5
  echo
  echo "Building libraw1394-$VER..."
  doWgetConfigure http://downloads.sourceforge.net/project/libraw1394/libraw1394 \
    libraw1394-$VER.tar.gz \
    libraw1394-$VER
}


function make_libdc1394 {
  VER=2.2.1
  echo
  echo "Building libdc1394-$VER..."
  doWgetConfigure \
    http://sourceforge.net/projects/libdc1394/files/libdc1394-2/$VER \
    libdc1394-$VER.tar.gz \
    libdc1394-$VER
}

function make_opencoreamr {
  VER=0.1.2
  echo
  echo "Building opencoreamr-$VER..."
  doWgetConfigure \
    http://downloads.sourceforge.net/project/opencore-amr/opencore-amr/$VER \
    opencore-amr-$VER.tar.gz \
    opencore-amr-$VER
}

function make_mplayercodecs {
  VER=20071007
  echo "Building essential-$VER..."
  doWgetBz2 http://www.mplayerhq.hu/MPlayer/releases/codecs \
    essential-$VER.tar.bz2 \
    essential-$VER
  cd ..
}

function make_madplay {
  VER=0.15.2b
  echo
  echo "Building madplay-$VER..."
  doWgetConfigure http://sourceforge.net/projects/mad/files/madplay/$VER \
    madplay-$VER.tar.gz \
    madplay-$VER
}

function make_libmad {
  VER=0.15.1b
  echo
  echo "Building libmad-$VER..."
  doWgetConfigure http://sourceforge.net/projects/mad/files/libmad/$VER \
    libmad-$VER.tar.gz \
    libmad-$VER
}

function make_libid3tag {
  VER=0.15.1b
  echo
  echo "Building libid3tag..."
  doWgetConfigure http://sourceforge.net/projects/mad/files/libid3tag/$VER \
    libid3tag-$VER.tar.gz \
    libid3tag-$VER
}

function make_sox {
  VER=14.4.1
  echo
  echo "Building sox-$VER..."
  doWgetConfigure http://sourceforge.net/projects/sox/files/sox/$VER \
    sox-$VER.tar.gz \
    sox-$VER \
    --disable-shared
}

function make_ffmpeg {
  echo
  echo "Building ffmpeg..."
  if [ ! -d ffmpeg ] ; then
    git clone git://source.ffmpeg.org/ffmpeg
    cd ffmpeg
  else
    cd ffmpeg
    git pull
  fi
  if [ ! -f config.log ] ; then
    ./configure \
      --enable-gpl \
      --enable-libmp3lame \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --disable-opencl \
      --enable-version3 \
      --enable-nonfree \
      --enable-postproc \
      --enable-avfilter \
      --enable-pthreads \
      --enable-libxvid \
      --enable-libmp3lame \
      --disable-ffserver \
      --disable-ffplay \
      --arch=x86_64 \
      --enable-libopencore-amrnb \
      --enable-libopencore-amrwb \
      || exit

  fi
  make || exit
  echo "Installing ffmpeg"
  sudo make install || exit
  echo "Installed ffmpeg"
  cd ..
}


if [ ! "$1" == "" ] ; then
	eval $1
	exit
fi

make_yasm
make_x264
make_xvidcore
make_lame
make_a52dec
make_faad2
make_faac
make_libraw1394
make_libdc1394
make_opencoreamr
make_libogg
make_libtheora
make_libvorbis
make_voaacenc
make_libvpx
make_zlib
make_ffmpeg
make_mplayercodecs
make_libmad
make_libid3tag
make_madplay
make_sox


