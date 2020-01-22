FROM ubuntu:16.04
MAINTAINER cocus

#install and source ansible
RUN apt-get update && apt-get install -y \
	dosbox \
	p7zip-full \
	wget

RUN mkdir /msvc
WORKDIR /msvc
# Fetch 7z from WinWorldPC
# Note: If I'm not mistaken, 47c39fe2-809a-6218-c39a-11c3a4e284a2 is the
# app/file GUID of wwpc; and the other one is the GUID of the download mirror.
# If, for some reason you need to change those, please visit the website first,
# and grab an up-to-date link to it.
RUN wget -O msvc.7z https://winworldpc.com/download/47c39fe2-809a-6218-c39a-11c3a4e284a2/from/c39ac2af-c381-c2bf-1b25-11c3a4e284a2
# Unpack it to /tmp/msvc
RUN mkdir /tmp/msvc
RUN 7z e -o/tmp/msvc msvc.7z
RUN rm msvc.7z
# Unpack the ISO to /tmp/msvc
# Note: it skips the extraction of MSVC20, WINCIM, WIN32S, MSVCCDK, SETUP.EXE, MSETUP.EXE and MSETUP.HLP
RUN 7z x '-x!MSVC20' '-x!WINCIM' '-x!WIN32S' '-x!MSVCCDK' '-x!SETUP.EXE' '-x!MSETUP.EXE' '-x!MSETUP.HLP' -o/tmp/msvc /tmp/msvc/msvc20.iso
# And move MSVC15 it to /msvc/MSVC
RUN mv /tmp/msvc/MSVC15 /msvc/MSVC
RUN rm -rf /tmp/msvc
# Generate the msvcvars.bat
RUN echo "@echo off" >> /msvc/MSVC/BIN/msvcvars.bat
RUN echo "set TOOLROOTDIR=C:\MSVC" >> /msvc/MSVC/BIN/msvcvars.bat
RUN echo "set PATH=C:\MSVC\BIN;%PATH%" >> /msvc/MSVC/BIN/msvcvars.bat
RUN echo "set INCLUDE=C:\MSVC\INCLUDE;C:\MSVC\MFC\INCLUDE;%INCLUDE%" >> /msvc/MSVC/BIN/msvcvars.bat
RUN echo "set LIB=C:\MSVC\LIB;C:\MSVC\MFC\LIB;%LIB%" >> /msvc/MSVC/BIN/msvcvars.bat
RUN echo "set INIT=C:\MSVC;%INIT%" >> /msvc/MSVC/BIN/msvcvars.bat

WORKDIR /root/.dosbox/
# Create an initial dosbox.conf file
RUN export TERM=linux && timeout 1 dosbox; exit 0
# This is rather crappy, it might be replaced with a proper alternative
RUN cp dos*.conf db.conf
RUN echo "mount C: /msvc" >> db.conf
RUN echo "mount D: /shared" >> db.conf
RUN echo "D:\\" >> db.conf
RUN echo "cibuild.bat" >> db.conf
RUN echo "exit" >> db.conf
RUN FNAME=`basename dos*.conf`; mv db.conf $FNAME

# Main CI runs here
ENV SDL_VIDEODRIVER dummy
WORKDIR /shared
# Note: dosbox should start executing the commands
# given on the previous steps and headless
ENTRYPOINT exec dosbox
