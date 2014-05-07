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
    sudo apt-get update
    sudo apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev libtheora-dev libtool libvorbis-dev libxfixes-dev pkg-config texi2html zlib1g-dev

    CUR=$PWD    

    sudo apt-get install yasm

    download http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 last_x264.tar.bz2 
    tar xjvf last_x264.tar.bz2
    cd x264-snapshot*
    ./configure --prefix="$CUR/ffmpeg_build" --enable-static
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

fi

case $PLATFORM in
    android-arm)
        cd $X264
        ./configure --enable-static --enable-pic --disable-cli --cross-prefix="$ANDROID_BIN-" --sysroot="$ANDROID_ROOT" --host=arm-linux --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" --extra-ldflags="-nostdlib -Wl,--fix-cortex-a8 -lgcc -ldl -lz -lm -lc"
        make -j4
        cd ..
        patch -Np1 < ../../ffmpeg-$FFMPEG_VERSION-android.patch
        ./configure --prefix="$ANDROID_NDK/../local/" --enable-shared --enable-gpl --enable-version3 --enable-runtime-cpudetect --disable-outdev=sdl --enable-libx264 --extra-cflags="-I$X264" --extra-ldflags="-L$X264" --enable-cross-compile --cross-prefix="$ANDROID_BIN-" --sysroot="$ANDROID_ROOT" --target-os=linux --arch=arm --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" --extra-ldflags="-nostdlib -Wl,--fix-cortex-a8" --extra-libs="-lgcc -ldl -lz -lm -lc" --disable-symver --disable-programs --libdir="$ANDROID_NDK/../local/lib/armeabi/" --shlibdir="$ANDROID_NDK/../local/lib/armeabi/"
        make -j4
        make install
        ;;
     android-x86)
        cd $X264
        ./configure --enable-static --enable-pic --disable-cli --cross-prefix="$ANDROID_BIN-" --sysroot="$ANDROID_ROOT" --host=i686-linux --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -mtune=atom -mssse3 -mfpmath=sse -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" --extra-ldflags="-nostdlib -lgcc -ldl -lz -lm -lc"
        make -j4
        cd ..
        patch -Np1 < ../../ffmpeg-$FFMPEG_VERSION-android.patch
        ./configure --prefix="$ANDROID_NDK/../local/" --enable-shared --enable-gpl --enable-version3 --enable-runtime-cpudetect --disable-outdev=sdl --enable-libx264 --extra-cflags="-I$X264" --extra-ldflags="-L$X264" --enable-cross-compile --cross-prefix="$ANDROID_BIN-" --sysroot="$ANDROID_ROOT" --target-os=linux --arch=atom --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -mssse3 -mfpmath=sse -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" --extra-ldflags="-nostdlib" --extra-libs="-lgcc -ldl -lz -lm -lc" --disable-symver --disable-programs --libdir="$ANDROID_NDK/../local/lib/x86/" --shlibdir="$ANDROID_NDK/../local/lib/x86/"
        make -j4
        make install
        ;;
    linux-x86)
        cd $X264
        ./configure --enable-static --enable-pic --host=i686-linux
        make -j4
        cd ..
        ./configure --enable-shared --enable-gpl --enable-version3 --enable-runtime-cpudetect --disable-outdev=sdl --enable-libx264 --extra-cflags="-I$X264" --extra-ldflags="-L$X264" --cc="gcc -m32" --extra-ldflags="-ldl" --libdir=/usr/local/lib32/ --shlibdir=/usr/local/lib32/
        make -j4
        sudo make install
        ;;
    linux-x86_64)
        
        ;;
    macosx-x86_64)
        cd $X264
        ./configure --enable-static --enable-pic
        make -j4
        cd ..
        ./configure --enable-shared --enable-gpl --enable-version3 --enable-runtime-cpudetect --disable-outdev=sdl --enable-libx264 --extra-cflags="-I$X264" --extra-ldflags="-L$X264" --extra-ldflags="-Wl,-headerpad_max_install_names -ldl"
        make -j4
        sudo make install
        BADPATH=/usr/local/lib
        LIBS="libavcodec.55.dylib libavdevice.55.dylib libavfilter.4.dylib libavformat.55.dylib libavutil.52.dylib libpostproc.52.dylib libswresample.0.dylib libswscale.2.dylib"
        for f in $LIBS; do sudo install_name_tool $BADPATH/$f -id @rpath/$f \
            -add_rpath /usr/local/lib/ -add_rpath /opt/local/lib/ -add_rpath @loader_path/. \
            -change $BADPATH/libavcodec.55.dylib @rpath/libavcodec.55.dylib \
            -change $BADPATH/libavdevice.55.dylib @rpath/libavdevice.55.dylib \
            -change $BADPATH/libavfilter.4.dylib @rpath/libavfilter.4.dylib \
            -change $BADPATH/libavformat.55.dylib @rpath/libavformat.55.dylib \
            -change $BADPATH/libavutil.52.dylib @rpath/libavutil.52.dylib \
            -change $BADPATH/libpostproc.52.dylib @rpath/libpostproc.52.dylib \
            -change $BADPATH/libswresample.0.dylib @rpath/libswresample.0.dylib \
            -change $BADPATH/libswscale.2.dylib @rpath/libswscale.2.dylib; done
        ;;
    windows-x86)
        7za x -y ffmpeg-$FFMPEG_VERSION-win32-dev.7z
        7za x -y ffmpeg-$FFMPEG_VERSION-win32-shared.7z
        patch -Np1 -d ffmpeg-$FFMPEG_VERSION-win32-dev/ < ../ffmpeg-$FFMPEG_VERSION-win32-dev.patch
        # http://ffmpeg.org/platform.html#Linking-to-FFmpeg-with-Microsoft-Visual-C_002b_002b
        LIBS=(avcodec-55 avdevice-55 avfilter-4 avformat-55 avutil-52 postproc-52 swresample-0 swscale-2)
        for LIB in ${LIBS[@]}; do
            lib /def:ffmpeg-$FFMPEG_VERSION-win32-dev/lib/$LIB.def /out:ffmpeg-$FFMPEG_VERSION-win32-dev/lib/$LIB.lib /machine:x86
        done
        rm -Rf ffmpeg-$FFMPEG_VERSION-win32-dev/lib32
        rm -Rf ffmpeg-$FFMPEG_VERSION-win32-shared/bin32
        mv ffmpeg-$FFMPEG_VERSION-win32-dev/lib ffmpeg-$FFMPEG_VERSION-win32-dev/lib32
        mv ffmpeg-$FFMPEG_VERSION-win32-shared/bin ffmpeg-$FFMPEG_VERSION-win32-shared/bin32
        cp -a ffmpeg-$FFMPEG_VERSION-win32-dev/* $INSTALL_DIR
        cp -a ffmpeg-$FFMPEG_VERSION-win32-shared/* $INSTALL_DIR
        ;;
    windows-x86_64)
        7za x -y ffmpeg-$FFMPEG_VERSION-win64-dev.7z
        7za x -y ffmpeg-$FFMPEG_VERSION-win64-shared.7z
        patch -Np1 -d ffmpeg-$FFMPEG_VERSION-win64-dev/ < ../ffmpeg-$FFMPEG_VERSION-win64-dev.patch
        # http://ffmpeg.org/platform.html#Linking-to-FFmpeg-with-Microsoft-Visual-C_002b_002b
        LIBS=(avcodec-55 avdevice-55 avfilter-4 avformat-55 avutil-52 postproc-52 swresample-0 swscale-2)
        for LIB in ${LIBS[@]}; do
            lib /def:ffmpeg-$FFMPEG_VERSION-win64-dev/lib/$LIB.def /out:ffmpeg-$FFMPEG_VERSION-win64-dev/lib/$LIB.lib /machine:x64
        done
        rm -Rf ffmpeg-$FFMPEG_VERSION-win64-dev/lib64
        rm -Rf ffmpeg-$FFMPEG_VERSION-win64-shared/bin64
        mv ffmpeg-$FFMPEG_VERSION-win64-dev/lib ffmpeg-$FFMPEG_VERSION-win64-dev/lib64
        mv ffmpeg-$FFMPEG_VERSION-win64-shared/bin ffmpeg-$FFMPEG_VERSION-win64-shared/bin64
        cp -a ffmpeg-$FFMPEG_VERSION-win64-dev/* $INSTALL_DIR
        cp -a ffmpeg-$FFMPEG_VERSION-win64-shared/* $INSTALL_DIR
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

if [[ $PLATFORM != windows* ]]; then
    cd ..
fi
