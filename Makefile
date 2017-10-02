# STM32 Makefile for GNU toolchain and openocd
#
# This Makefile fetches the Cube firmware package from ST's' website.
# This includes: CMSIS, STM32 HAL, BSPs, USB drivers and examples.
#
# Usage:
#	make cube		Download and unzip Cube firmware
#	make program		Flash the board with OpenOCD
#	make openocd		Start OpenOCD
#	make debug		Start GDB and attach to OpenOCD
#	make dirs		Create subdirs like obj, dep, ..
#	make template		Prepare a simple example project in this dir
#
# Copyright	2015 Steffen Vogel
# License	http://www.gnu.org/licenses/gpl.txt GNU Public License
# Author	Steffen Vogel <post@steffenvogel.de>
# Link		http://www.steffenvogel.de
#
# edited for the STM32L152RE Nucleo by Giovanni Camurati

# A name common to all output files (elf, map, hex, bin, lst)
TARGET     = demo

# Take a look into $(CUBE_DIR)/Drivers/BSP for available BSPs
# name needed in upper case and lower case
BOARD      = STM32L152RE-Nucleo
BOARD_UC   = STM32L152RE_NUCLEO
BOARD_LC   = stm32l1xx_nucleo
BSP_BASE   = $(BOARD_LC)

OCDFLAGS   = -f board/st_nucleo_l1.cfg
GDBFLAGS   =

#EXAMPLE   = Templates
EXAMPLE    = Examples/RCC/RCC_ClockConfig

# MCU family and type in various capitalizations o_O
MCU_FAMILY = stm32l1xx
MCU_LC     = stm32l152xe
MCU_MC     = STM32L152xE
MCU_UC     = STM32L152RE

# path of the ld-file inside the example directories
LDFILE     = $(EXAMPLE)/SW4STM32/$(BOARD_UC)/$(MCU_UC)Tx_FLASH.ld
#LDFILE     = $(EXAMPLE)/TrueSTUDIO/$(BOARD_UC)/$(MCU_UC)_FLASH.ld

# Your C files from the /src directory
SRCS       = main.c
SRCS      += system_$(MCU_FAMILY).c
SRCS      += stm32l1xx_it.c

# Basic HAL libraries
SRCS      += stm32l1xx_hal_rcc.c stm32l1xx_hal_rcc_ex.c stm32l1xx_hal.c stm32l1xx_hal_cortex.c stm32l1xx_hal_gpio.c stm32l1xx_hal_pwr_ex.c $(BSP_BASE).c

# Directories
OCD_DIR    = /usr/share/openocd/scripts

CUBE_DIR   = cube

BSP_DIR    = $(CUBE_DIR)/Drivers/BSP/STM32L1xx_Nucleo/
HAL_DIR    = $(CUBE_DIR)/Drivers/STM32L1xx_HAL_Driver
CMSIS_DIR  = $(CUBE_DIR)/Drivers/CMSIS

DEV_DIR    = $(CMSIS_DIR)/Device/ST/STM32L1xx

CUBE_URL   = http://www.st.com/st-web-ui/static/active/en/st_prod_software_internet/resource/technical/software/firmware/stm32cubel1.zip

# that's it, no need to change anything below this line!

###############################################################################
# Toolchain

PREFIX     = arm-none-eabi
CC         = $(PREFIX)-gcc
AR         = $(PREFIX)-ar
OBJCOPY    = $(PREFIX)-objcopy
OBJDUMP    = $(PREFIX)-objdump
SIZE       = $(PREFIX)-size
GDB        = $(PREFIX)-gdb

OCD        = openocd

###############################################################################
# Options

# Defines
DEFS       = -D$(MCU_MC) -DUSE_HAL_DRIVER

# Debug specific definitions for semihosting
DEFS       += -DUSE_DBPRINTF

# Include search paths (-I)
INCS       = -Isrc
INCS      += -I$(BSP_DIR)
INCS      += -I$(CMSIS_DIR)/Include
INCS      += -I$(DEV_DIR)/Include
INCS      += -I$(HAL_DIR)/Inc

# Library search paths
LIBS       = -L$(CMSIS_DIR)/Lib

# Compiler flags
CFLAGS     = -g -march=armv7-m -mthumb -mcpu=cortex-m3 -Wa,-mimplicit-it=thumb
#CFLAGS     = -Wall -g -std=c99 -Os
#CFLAGS    += -mlittle-endian -mcpu=cortex-m3 -march=armv7e-m -mthumb
#CFLAGS    += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
#CFLAGS    += -ffunction-sections -fdata-sections
CFLAGS     += $(INCS) $(DEFS)

# Linker flags
LDFLAGS    = -Wl,--gc-sections -Wl,-Map=$(TARGET).map $(LIBS) -T$(MCU_LC).ld

# Enable Semihosting
LDFLAGS   += --specs=rdimon.specs -lc -lrdimon

# Source search paths
VPATH      = ./src
VPATH     += $(BSP_DIR)
VPATH     += $(HAL_DIR)/Src
VPATH     += $(DEV_DIR)/Source/

OBJS       = $(addprefix obj/,$(SRCS:.c=.o))
LLS        = $(addprefix ll/,$(SRCS:.c=.ll))
DEPS       = $(addprefix dep/,$(SRCS:.c=.d))

# CLANG & LLVM
CLANG_PATH=../Inception/tools/llvm/build_debug/Debug+Asserts/bin/
CLANG=$(CLANG_PATH)/clang
LLVM-LINK=$(CLANG_PATH)/llvm-link
LLVM-AS=$(CLANG_PATH)/llvm-as

CLANG_FLAGS=-mthumb --target=thumbv7m-eabi -mcpu=cortex-m3
CLANG_FLAGS    += -ffunction-sections -fdata-sections
CLANG_FLAGS    += $(INCS) $(DEFS)
CLANG_FLAGS    += -emit-llvm -g -S
CLANG_FLAGS    += ../Inception/Analyzer/include/

INCEPTION-CL=../Inception/Compiler/Debug+Asserts/bin/inception-cl
INCEPTION_FLAGS=

# Prettify output
V = 0
ifeq ($V, 0)
	Q = @
	P = > /dev/null
endif

###################################################

.PHONY: all dirs program debug template clean inception native run-klee

all: inception

-include $(DEPS)

dirs: dep obj ll cube
dep obj src ll:
	@echo "[MKDIR]   $@"
	$Qmkdir -p $@

obj/%.o : %.c | $(dirs)
	@echo "[CC]      $(notdir $<)"
	$Q$(CC) $(CFLAGS) -c -o $@ $< -MMD -MF dep/$(*F).d

$(TARGET).elf: $(OBJS)
	@echo "[LD]      $(TARGET).elf"
	$Q$(CC) $(CFLAGS) $(LDFLAGS) src/startup_$(MCU_LC).s $^ -o $@
	@echo "[OBJDUMP] $(TARGET).lst"
	$Q$(OBJDUMP) -St $(TARGET).elf >$(TARGET).lst
	@echo "[SIZE]    $(TARGET).elf"
	$(SIZE) $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	@echo "[OBJCOPY] $(TARGET).bin"
	$Q$(OBJCOPY) -O binary $< $@

native: $(TARGET).bin

ll/%.ll : %.c | $(dirs)
	@echo "[CLANG] $(notdir $<)"
	$Q$(CLANG) $(CLANG_FLAGS) -o $@ $<

$(TARGET).ll: $(LLS)
	@echo "[LLVM-LINK] $(TARGET).ll"
	$Q$(LLVM-LINK) -S $(LLS)  -o $(TARGET).ll

$(TARGET).bc: $(TARGET).ll native
	@echo "[LLVM-AS] $(TARGET).bc"
	$Q$(LLVM-AS) $(TARGET).ll -o $(TARGET).bc
	@echo "[INCEPTION-CL] $(TARGET).elf $(TARGET).bc"
	$Q$(INCEPTION-CL) $(INCEPTION_FLAGS) $(TARGET).elf $(TARGET).bc

inception: $(TARGET).bc


openocd:
	$(OCD) -s $(OCD_DIR) $(OCDFLAGS)

program: all
	$(OCD) -s $(OCD_DIR) $(OCDFLAGS) -c "program $(TARGET).elf verify reset"

debug:
	@if ! nc -z localhost 3333; then \
		echo "\n\t[Error] OpenOCD is not running! Start it with: 'make openocd'\n"; exit 1; \
	else \
		$(GDB)  -ex "target extended localhost:3333" \
			-ex "monitor arm semihosting enable" \
			-ex "monitor reset halt" \
			-ex "load" \
			-ex "monitor reset init" \
			$(GDBFLAGS) $(TARGET).elf; \
	fi

cube:
	rm -fr $(CUBE_DIR)
	wget -O /tmp/cube.zip $(CUBE_URL)
	unzip /tmp/cube.zip
	mv STM32Cube* $(CUBE_DIR)
	chmod -R u+w $(CUBE_DIR)
	rm -f /tmp/cube.zip

template: cube src
	cp -ri $(CUBE_DIR)/Projects/$(BOARD)/$(EXAMPLE)/Src/* src
	cp -ri $(CUBE_DIR)/Projects/$(BOARD)/$(EXAMPLE)/Inc/* src
	cp -i $(DEV_DIR)/Source/Templates/gcc/startup_$(MCU_LC).s src
	cp -i $(CUBE_DIR)/Projects/$(BOARD)/$(LDFILE) $(MCU_LC).ld

run-klee:
	klee --search=dfs $(TARGET).bc

clean: clean-native clean-inception clean-klee

clean-native:
	@echo "[RM]      $(TARGET).bin"; rm -f $(TARGET).bin
	@echo "[RM]      $(TARGET).elf"; rm -f $(TARGET).elf
	@echo "[RM]      $(TARGET).map"; rm -f $(TARGET).map
	@echo "[RM]      $(TARGET).lst"; rm -f $(TARGET).lst
	@echo "[RMDIR]   dep"          ; rm -fr dep
	@echo "[RMDIR]   obj"          ; rm -fr obj

clean-inception:
	@echo "[RM]      $(TARGET).ll" ; rm -f $(TARGET).ll
	@echo "[RM]      $(TARGET).bc" ; rm -f $(TARGET).bc
	@echo "[RMDIR]   ll"           ; rm -fr ll

clean-klee:
	@echo "[RM]      klee*" ; rm -rf klee*
