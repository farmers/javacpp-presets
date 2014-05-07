if [[ -z "$PLATFORM" ]]; then
    echo "This file is meant to be included by the parent cppbuild.sh script"
    exit 1
fi

if [[ $PLATFORM == windows* ]]; then
    FFMPEG_VERSION=2.2.1
    download http://ffmpeg.zeranoe.com/builds/win32/dev/ffmpeg-$FFMPEG_VERSION-win32-dev.7z ffmpeg-$FFMPEG_VERSION-win32-dev.7z
    download http://ffmpeg.zeranoe.com/builds/win64/dev/ffmpeg-$FFMPEG_VERSION-win64-dev.7z ffmpeg-$FFMPEG_VERSION-win64-dev.7z
    download http://ffmpeg.zeranoe.com/builds/win32/shared/ffmpeg-$FFMPEG_VERSION-win32-shared.7z ffmpeg-$FFMPEG_VERSION-win32-shared.7z
    download http://ffmpeg.zeranoe.com/builds/win64/shared/ffmpeg-$FFMPEG_VERSION-win64-shared.7z ffmpeg-$FFMPEG_VERSION-win64-shared.7z
    download http://msinttypes.googlecode.com/files/msinttypes-r26.zip msinttypes-r26.zip

    INSTALL_DIR=/C/MinGW/local
    mkdir -p $INSTALL_DIR/include
    unzip -o msinttypes-r26.zip -d $INSTALL_DIR/include
else
   

    CUR=$PWD    

   

    download http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 last_x264.tar.bz2 
    tar xjvf last_x264.tar.bz2
    cd x264-snapshot*
    ./configure --prefix="$CUR/ffmpeg_build" --enable-static --enable-pic
    make
    sudo make install
    make distclean
    cd ..

    download https://github.com/mstorsjo/fdk-aac/zipball/master fdk-aac.zip
    unzip fdk-aac.zip
    cd mstorsjo-fdk-aac*
    autoreconf -fiv
    ./configure --prefix="$CUR/ffmpeg_build" --disable-shared
    make
    sudo make install
    make distclean
    cd ..

    sudo apt-get install libmp3lame-dev
    sudo apt-get install libopus-dev

    download http://webm.googlecode.com/files/libvpx-v1.3.0.tar.bz2 libvpx-v1.3.0.tar.bz2
    tar xjvf libvpx-v1.3.0.tar.bz2
    cd libvpx-v1.3.0
    ./configure --prefix="$CUR/ffmpeg_build" --disable-examples
    make
    sudo make install
    make clean
    cd ..

    

    FFMPEG_VERSION=2.2.1
    download http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2 ffmpeg-$FFMPEG_VERSION.tar.bz2

    tar -xjvf ffmpeg-$FFMPEG_VERSION.tar.bz2
    cd ffmpeg
    PKG_CONFIG_PATH="$CUR/ffmpeg_build/lib/pkgconfig"
    export PKG_CONFIG_PATH

    ./configure --prefix="$CUR/ffmpeg_build" --extra-cflags="-I$CUR/ffmpeg_build/include" --extra-ldflags="-L$CUR/ffmpeg_build/lib" --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree --shlibdir=/usr/local/lib64/ --libdir=/usr/local/lib64 --enable-shared --enable-version3 --enable-runtime-cpudetect --disable-outdev=sdl

    make
    sudo make install
    make distclean
    
    cd ..

fi
