# Amstrad File Archive Project

## Description

This repository contains a certain amount of Amstrad CPC demos accessible from files.
You will not found DSK here, just Amsdos Compatible files.
You can copy them in a real floppy disc, or in a mass storage support supported by a dedicated OS.

Some files may not be original but modified files and hacked files to allow a loading with modern mass storage.

Fill free to propose any merge request to improve the organisation of the archive or provide additional files.

## How to launch on a real CPC

### With a floppy disc

TODO

### With an Albireo with UNIDOS

TODO

### With a M4

TODO


## How to launch with an emulator with UNIDOS

1. Download AceDL <https://roudoudou.com/ACE-DL/>
2. Select your folder of intest and file to launch :

  - In a console on the PC: `.\AceDL\AceDL.exe -plugin reset -plugin albireo1 -albipath .\DEMOS\BENEDICT\BLOCUS\` (to select the files in folder `.\DEMOS\BENEDICT\BLOCUS\`)
  - On the emulator:

    - Select Albireo folder: `LOAD"SD:`
    - Optionnaly, list the files to know which one to launch: `CAT`
    - Launch the file: `RUN"BLOCUS` to launch the `BLOCUS` file