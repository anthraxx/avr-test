
all:
	toggle-led

test: toggle-led flash

toggle-led:
	avr-gcc -mmcu=atmega8 -Wall -Os -o toggle_led.elf toggle_led.c
	avr-objcopy -j .text -O ihex toggle_led.elf toggle_led.hex

flash:
	avrdude -p m8 -c stk500v2 -e -U flash:w:toggle_led.hex -P /dev/ttyUSB0 -v

