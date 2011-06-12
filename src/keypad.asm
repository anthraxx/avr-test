.include "m8def.inc"

; Stack initialisieren
; http://www.mikrocontroller.net/articles/AVR-Tutorial:_Stack
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16

; Die Hauptschleife prueft, welcher Key gerade gedrueckt ist
; und laesst die LEDs auf PORTC dann der Ziffer entsprechend
; haeufig blinken (* = 10, # = 11)
mainloop:
    rcall getkey
    rcall blink
    rjmp mainloop

;; blink: Laest eine LED blinken, indem es an ganz PORTC
;; entsprechende Signale sendet.
;; Parameter: Blinkhaeufigkeit (in r16)
;; Rueckgabe: Keine
;; Verwendete Register: r16 - Blinklaenge
;;                      r18 - Blinkzaehler (zum dekr.)
;;                      r19 - Werte der LEDs
blink:
    mov r18, r16
    sec
    adc r18, r16
    ldi r19, 0xff
    out DDRC, r19
    out PORTC, r19
blinkloop:
    dec r18
    breq blinkend
    ldi r16, 250
    rcall delay
    com r19
    out PORTC, r19
    rjmp blinkloop
blinkend:
    ret

;; delay: Laesst den Microcontroller fuer eine bestimmte Anzahl
;; Milisekunden "schlafen". Die Dauer unterliegt kleineren
;; Ungenauigkeiten. Nimmt an, dass der Takt 1 MHz ist.
;; Parameter: Anzahl Milisekunden in r16
;; Rueckgabe: keine
;; Verwendete Register: r16 - Milisekunden (wird dekr.)
;;                      r17 - Durchlauefe des 4-Takt-Loops (wird dekr.)
delay:
    ; Es wird 250 mal der sleeploop250 durchlaufen. Dieser ist
    ; 4 Takte lang, wenn die Schleife erneut durchlaufen wird,
    ; sonst 3. Somit wird dort 1 Milisekunde verbraten.
    ldi r17, 250
    cpi r16, 0
    breq sleepend
    dec r16
sleeploop250: 
    dec r17 ; 1 Takt
    nop ; 1 Takt
    brne sleeploop250 ; Wenn Sprung 2 Takte, sonst 1
    rjmp delay
sleepend:
    ret

;; getkey: Liest aus, welche Taste im Moment auf dem Numpad
;; gedrueckt ist.
;; Parameter: Keine
;; Rueckgabe: Gedrueckte Ziffer in r16 (11 fuer Sternchen,
;;            12 fuer Raute)
;; Verwendete Register: r16 - Werte von PIND (spaeter Rueckgabe)
;;                      r17 - Bitmaske fuer die jew. Zeile
getkey:
    .macro checkkey
        in r16, PIND
        ldi r17, @0
        and r17, r16
        brne @1
    .endm

    .macro retkey
        ldi r16, @0
        ret
    .endm

    .macro enablekeycol
        ldi r16, @0
        out PORTD, r16
        in r16, PIND
    .endm

    .equ KEYROW1 = 0b00000010
    .equ KEYROW2 = 0b01000000
    .equ KEYROW3 = 0b00100000
    .equ KEYROW4 = 0b00001000

    ; Passende PIN in Eingabe/Ausgabe schalten
    ldi r16, 0b00010101
    out DDRD, r16

    ; Erste Spalte
    enablekeycol 0b00000100
    checkkey KEYROW1, lkey3
    checkkey KEYROW2, lkey4
    checkkey KEYROW3, lkey7
    checkkey KEYROW4, lkeystar
    
    ; Zweite Spalte
    enablekeycol 0b00000001
    checkkey KEYROW1, lkey1
    checkkey KEYROW2, lkey5
    checkkey KEYROW3, lkey8
    checkkey KEYROW4, lkey0
    
    ; Dritte Spalte
    enablekeycol 0b00010000
    checkkey KEYROW1, lkey2
    checkkey KEYROW2, lkey6
    checkkey KEYROW3, lkey9
    checkkey KEYROW4, lkeyhash

    ; Keine Taste wurde gedrueckt
    retkey -1

lkey0: retkey 0
lkey1: retkey 1
lkey2: retkey 2
lkey3: retkey 3
lkey4: retkey 4
lkey5: retkey 5
lkey6: retkey 6
lkey7: retkey 7
lkey8: retkey 8
lkey9: retkey 9
lkeystar: retkey 10
lkeyhash: retkey 11

