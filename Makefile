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

all: start toggle_led finish

toggle_led: toggle_led.hex

%::src/%.elf
	echo "test"

start:
	mkdir -p ./bin 

finish:
	chmod -x bin/*.elf

%.elf:src/%.c
	$(CC) $(CFLAGS) -o bin/$@ $<

%.hex:bin/%.elf
	$(LD) $(LDFLAGS) $^ bin/$@ ${LDLIBS}

clean:
	${RM} ./bin/*

flash:
	${PR} ${PRFLAGS} -c ${DEVCTL} -e -U flash:w:bin/toggle_led.hex -P ${DEVPRG} -v

