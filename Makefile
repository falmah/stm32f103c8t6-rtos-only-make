
ROOT := $(realpath ./)
BUILD_DIR := $(ROOT)/build
SRC_DIR := $(ROOT)/src
HAL_DIR := $(SRC_DIR)/hal
CMSIS_DIR := $(HAL_DIR)/cmsis
SYSTEM_DIR := $(HAL_DIR)/stm32
RTOS_DIR := $(SRC_DIR)/rtos

CC := arm-none-eabi-gcc

INCLUDE = -I$(CMSIS_DIR)
INCLUDE += -I$(SYSTEM_DIR)
INCLUDE += -I$(RTOS_DIR)/include

CFLAGS_CORTEX = -mthumb -march=armv7-m -mcpu=cortex-m3 -mtune=cortex-m3 -fsingle-precision-constant

CFLAGS = -O0 -ggdb -Wall $(CFLAGS_CORTEX) $(INCLUDE)

SRC_C = $(wildcard $(RTOS_DIR)/*.c) \
		$(wildcard $(CMSIS_DIR)/*.c) \
		$(wildcard $(SRC_DIR)/*.c) \
		$(wildcard $(SYSTEM_DIR)/*.c) 
SRC_ASM += $(wildcard $(SYSTEM_DIR)/*.s)

OBJ = $(SRC_C:%.c=%.o) \
		$(SRC_ASM:%.s=%.o)

all: $(BUILD_DIR) $(BUILD_DIR)/firmware.elf

%.o: %.c
	$(CC) $(CFLAGS) -c -o $(addprefix $(BUILD_DIR)/, $(notdir $@)) $<

%.o: %.s
	$(CC) $(CFLAGS) -c -o $(addprefix $(BUILD_DIR)/, $(notdir $@)) $<

$(BUILD_DIR)/firmware.elf: $(OBJ)
	$(CC) -Tsrc/stm32f103x8.ld --specs=nosys.specs $(CFLAGS_CORTEX) $(addprefix $(BUILD_DIR)/, $(notdir $^)) -o $@

$(BUILD_DIR):
	@mkdir build

.PHONY: clean

clean:
	@rm -rf build