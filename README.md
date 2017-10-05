# STM32Cube Makefile

This is a template application for the STM32 ARM microcontrollers that compiles with GNU tools.

It serves as a quick-start for those who do not wish to use an IDE, but rather
develop in a text editor of choice and build from the command line.

We extended this makefile to use the Inception project.

## Connection to the stm32l152re board

There are several ways to connect to the board. Please follow these instructions.

1. **Configure the board**:
  1. dissolder the jumpers SB12 and SB15
  2. connect the following jumper wires
      - PB10  (red)     irq
      - PB12  (white)   irq_ack
      - PB13  (blue)    TMS
      - PB14  (green)   TCK
      - PB15  (yellow)  TDI
      - GND   (grey)    GND
      - PB3   (brown)   NRST
      - PB4   (orange)  TDO / SWO
  3. now you can chose between several configurations
    1. USB/SWD (requires to have the ST-Link part connected)
        - CN2 jumpers both ON
        - connect PB3 (brown)  with CN4[5]
        - connect PB4 (orange) with CN4[6]
        - now you can:
            - USB: 
                - connect to the host computer with an USB cable
                - you can now see the board as a device and you can
                  paste a binary into it to flash it
                - remember to reset the board to load and run the program
                - this is the option used by the `flash` target of the Makefile
            - SWD with OpenOCD and J-Link:
                - connect J-Link to the CN4 as follows:
                - [complete guide]: https://mcuoneclipse.com/2015/08/22/debugging-stm32f103rb-nucleo-board-with-with-segger-j-link/ 
                - VTref (1) with (CN4[1]) VDD_Target
                - GND (4) with (CN4[3]) GND
                - TMS (7) with (CN4[4]) SWDIO
                - TCK (9) with (CN4[2]) SWCKL
                - TDO (13) with (CN4[6]) SWO
                - Reset (15) with (CN4[5]) NRST
                - connect CN4[1] to +5V pin on the board
                - finally use OpenOCD with the proper configuration file:
                - `openocd -f /usr/share/openocd/scripts/board/st_nucleo_l1.cfg`
                - this method is used by the `program` target of the Makefile
    2. JTAG with OpenOCD and J-Link:
        - CN2 jumpers both OFF
        - connect J-Link to TCK,TMS,TDI,TDO,NREST,GND (pins specified at point 2)
        - finally use OpenOCD with the proper configuration file:
        - `openocd -f stm32-demos/openocd-jtag/st_nucleo_l1.cfg`
    3. JTAG with Inception RTDebugger
        - CN2 jumpers both OFF
        - connect the jumper wires specified at point 2 to the proper pins on the FPGA
        - refer to [RTDebugger]:https://gitlab.eurecom.fr/nasm/Inception-debugger/blob/master/scripts/pins
        - you can directly connect NRST to VCC
        - remember to **select the Daisy-chain option** on the FPGA by selectin SW4 = 1
        - remember to **set the correct irq_addr** on the FPGA:
        - currently: `picocom -b115200 -fn -pn -d8 -r -l /dev/ttyACM1`
        - `devmem 0x40000004 32 0x20002000` (see Stub example for the address)
        - `press pushbutton 1`
        - refer to [RTDebugger]:https://gitlab.eurecom.fr/nasm/Inception-debugger/blob/master/scripts/pins
        - use the [RTDebugger-driver]:https://gitlab.eurecom.fr/nasm/Inception-debugger-driver
        - or the  [Analyzer]:https://gitlab.eurecom.fr/nasm/Inception-analyzer
        - this method is used by the `run-klee` target of the Makefile

## Target Overview

  - `all`        Builds the binary and the llvm, it includes decompilation of asm.
  - `inception`  Builds the binary and the llvm, it includes decompilation of asm.
  - `native`     Builds the binary.
  - `run-klee`   Runs Inception's klee.
  - `program`    Flashes the ELF binary to the target board.
  - `flash`      Flashes the binary via USB and ST-Link.
  - `debug`      Launches GDB and connects to the target.
  - `cube`       Downloads the most recent STM32Cube version from the ST website and extract it to `cube`.
  - `template`   Copies a simple example/template, startup code and a linker script from the `cube` to your `src` directory.
  - `clean`      Remove all files and directories which have been created during the compilation.
  - `clean-klee` Remove all files and directories which have been created by Klee.

## Installing

Before building, you must install the GNU compiler toolchain.
I'm using the the `gnu-none-eabi` triple shipped with recent Debian and Ubuntu versions:

    sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi

You also might want to install some other libraries and debuggers:

    sudo apt-get install openocd gdb-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib

## Source code

Your source code has to be put in the `src` directory.
Dont forget to add your source files in the Makefile.

## Programming and debugging code on the board

First, make sure you have OpenOCD installed and in your path (see above).
Recent versions already come with full support for the discovery and nucleus boards.
Then connect your board, and load the application by saying:

    make program

To load the program and debug it using GDB, simply use the debug target:

    make debug

GDB connects to the board by launching OpenOCD in the background.
See [this blog post](http://www.mjblythe.com/hacks/2013/02/debugging-stm32-with-gdb-and-openocd/)
for info about how it works.

### UDEV Rules for the Discovery Boards

If you are not able to communicate with the Discovery board without
root privileges you should add [appropriate udev rules](49-stlink.rules).


