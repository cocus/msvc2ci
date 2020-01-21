# msvc2ci
Microsoft Visual C++ (16 bit version) dockerized using Dosbox for CI

# What is this thing?
This is a project that contains a Dockerfile that's the basis for https://hub.docker.com/repository/docker/cocusar/msvc2ci.
You can build this docker locally or pull it from docker hub by issuing `docker pull cocusar/msvc2ci`.

# Okay, but what's for?
Right, with this docker image you will be able to build projects that can be compiled directly with Visual C++ 2.0 for 16 bit development.
Yes, one of those decrepit versions of MSVC that can target DOS or Win3x.
In order to achieve this, Dosbox is used inside the docker image.
MSVC2.0 is pulled directly from the readily available ISO images on WinWorldPC (https://winworldpc.com/product/visual-c/2x); so this Dockerfile is completely clean.

# WHY???!1
So, have you heard about projects that target retro platforms? Well, this is one.

# Techincal info
* An anonymous volume is used to present the source files to the Dosbox inside the docker container. The mountpoint is set to `/shared`. Under DOS, this is mounted as drive letter `D:`
* MSVC gets mounted in the C drive, mimicking the behaviour of a default install of MSVC in the C: (i.e. `C:\MSVC`).
* The docker itself doesn't run any automated builds by itself, but it rather runs a .bat file that has the appropriate build steps for your project. This bat file is called `cibuild.bat` and should be placed inside the same anonymous volume where the sourcecode resides. The last step on the .bat file should be an `exit`!
* Dosbox runs headless, with a dummy SDL driver.
* Since Dosbox cannot redirect the stdout and stderr to a file using easily, you should redirect the output of build steps to a file. For instance, `nmake >> D:\build.txt`.
* This is not tied to NMake-only projects, but it was only tested with them.

# How to use it
First of all you'll need a working docker install on your system.

Then, follow these are the steps to try it out:
 1. Build an image locally:  
  1.1. `git clone https://github.com/cocus/msvc2ci.git`  
  1.2. `cd msvc2ci`  
  1.3. `docker build -t msvc2ci .`
 2. Use a helloworld NMake-based app for testing:   
  2.1. From the WinWorldPC site, grab the 7z image, uncompress it, mount the iso or uncompress it, and grab the folder from an example, like `\MSVC15\SAMPLES\TOOLHELP`.   
  2.2. Place it under a test directory, like `~/TOOLHELP` (so inside ~/TOOLHELP you have the files).
 3. Create an appropriate `cibuild.bat` file inside the source directory (`~/TOOLHELP/cibuild.bat` for this example):   
  3.1. Build variables should be placed in this file. Note that the default Dosbox config mounts the entire MSVC into `C:\MSVC` (like a default install would do), so the default variables should be used: 
    ```batch
    @echo off
    set TOOLROOTDIR=C:\MSVC
    set PATH=C:\MSVC\BIN;%PATH%
    set INCLUDE=C:\MSVC\INCLUDE;C:\MSVC\MFC\INCLUDE;%INCLUDE%
    set LIB=C:\MSVC\LIB;C:\MSVC\MFC\LIB;%LIB%
    set INIT=C:\MSVC;%INIT%
    ```
    3.2. Add the appropriate steps to build this code and exit! (note: D:\ corresponds to the shared source dir):
      ```batch
      nmake clean >> D:\build.txt
      nmake >> D:\build.txt
      exit
      ```
 4. Run a docker container to build it!   
   4.1 `docker run -it --rm -v$(readlink -f ~/TOOLHELP):/shared msvc2ci`
 5. Build output messages should be found on `~/TOOLHELP/BUILD.TXT` and artifacts should be there as well. Note that depending on the Makefile rules, the artifacts can be placed on another directory.
 
