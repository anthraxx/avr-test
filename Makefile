ASM=avra
CC=avr-gcc
PR=avrdude
LD=avr-objcopy

DEVPRG=/dev/ttyUSB0
DEVCTL=stk500v2
DEVMMCU=atmega8

CFLAGS=-Wall \
	   -Wextra \
	   -pedantic \
	   -Wuninitialized \
	   -Winit-self \
	   -mmcu=${DEVMMCU} \
	   -Os
PRFLAGS=-p m8
LDFLAGS=-j .text -O ihex
LDLIBS=
ASMINC=/usr/include/avr

all: start toggle_led keypad finish

toggle_led: toggle_led.elf toggle_led.hex

keypad: keypad.hex

start:
	mkdir -p ./bin 

finish:
	chmod -x bin/*.elf

%.hex:src/%.asm
	$(ASM) -I $(ASMINC) -o bin/$@ $<
	mv src/*.hex src/*.obj src/*.cof bin/

%.elf:src/%.c
	$(CC) $(CFLAGS) -o bin/$@ $<

%.hex:bin/%.elf
	$(LD) $(LDFLAGS) $^ bin/$@ ${LDLIBS}

clean:
	${RM} ./bin/*

flash-keypad flash-toggle-led flash-%:
	${PR} ${PRFLAGS} -c ${DEVCTL} -e -U flash:w:bin/$(subst flash-,,$@).hex -P ${DEVPRG} -v

