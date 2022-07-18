choco install make
http://gnuwin32.sourceforge.net/packages/coreutils.htm
http://gnuwin32.sourceforge.net/packages/libiconv.htm
http://gnuwin32.sourceforge.net/packages/libintl.htm

mkdir temp

cd .\subprojects\bgfx\bgfx\
make mingw-gcc-debug64 MINGW="C:/Program Files/mingw-w64/x86_64-8.1.0-posix-seh-rt_v6-rev0/mingw64"
make tools MINGW="C:/Program Files/mingw-w64/x86_64-8.1.0-posix-seh-rt_v6-rev0/mingw64"