.DEFAULT_GOAL := all

ECLIPSE_HOME  := $(eclipse_home)

# lookup table for the target specific template
IT_FILE_KSGER_V1_5       := stm32f1xx_it.c
IT_FILE_KSGER_V2         := stm32f1xx_it.c
IT_FILE_KSGER_V3         := stm32f1xx_it.c
IT_FILE_Quicko_STM32F103 := stm32f1xx_it.c
IT_FILE_Quicko_STM32F072 := stm32f0xx_it.c

# cubeMx related vars
STM32CUBEMX  := $(shell sh -c "find \"$(ECLIPSE_HOME)/plugins\" -name \"STM32CubeMX.jar\" -maxdepth 2 -mindepth 2")
PRJ_DIR      := $(shell sh -c "pwd")
JRE_PLUGIN   := $(shell sh -c "find \"$(ECLIPSE_HOME)/plugins\" -name \"com.st.stm32cube.ide.jre.*\" -maxdepth 1 -type d")
JAVA         := $(JRE_PLUGIN)/jre/bin/java

# the default make in the STM32CubeMX is from 2016, does not support grouped targets
# if they decide to update make use grouped targets, that solve the issue of copying a template then running the cubemx generator on it. 
# Use the "&:" instead of ":" to define grouped targets and include the copied files one by one.

# use a dummy "generated" file as a target
.SECONDEXPANSION: 
./boards/%/src/generated : ./mcu/templates/main.c ./mcu/templates/main.h $$(subst _BOARD_,%,./boards/_BOARD_/src/_BOARD_.ioc) ./mcu/templates/$$(IT_FILE_%)
	sh -c "cp ./mcu/templates/${IT_FILE_$*} ./boards/$*/src/Core/Src/${IT_FILE_$*}"
	sh -c "cp ./mcu/templates/main.c        ./boards/$*/src/Core/Src/main.c"
	sh -c "cp ./mcu/templates/main.h        ./boards/$*/src/Core/Inc/main.h"
	sh -c "cd \"$(PRJ_DIR)/boards/$*/src\"; \"$(JAVA)\" -jar \"$(STM32CUBEMX)\" -q cubemx_gen_script"
	sh -c "touch ./boards/$*/src/generated"

all : ./boards/KSGER_V1_5/src/generated       \
	  ./boards/KSGER_V2/src/generated         \
	  ./boards/KSGER_V3/src/generated         \
	  ./boards/Quicko_STM32F103/src/generated \
	  ./boards/Quicko_STM32F072/src/generated ;

clean_% :
	sh -c "rm -f  ./boards/$*/src/generated"
	sh -c "rm -rf ./boards/$*/src//EWARM"
	sh -c "cd ./boards/$*/src/Core/Inc; find . -not -name 'GENERATED_FILES_DO_NOT_MODIFY' -delete"
	sh -c "cd ./boards/$*/src/Core/Src; find . -not -name 'GENERATED_FILES_DO_NOT_MODIFY' -delete"
	sh -c "cd ./boards/$*/src/Drivers;  find . -not -name 'GENERATED_FILES_DO_NOT_MODIFY' -delete"
	
clean : clean_KSGER_V1_5       \
	    clean_KSGER_V2         \
	    clean_KSGER_V3         \
	    clean_Quicko_STM32F103 \
	    clean_Quicko_STM32F072 ;
