/*
    toggle_led.c
    Copyright (C) 2006 Micah Carrick   <email@micahcarrick.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#define KEYPAD_LEN 3

#define F_CPU 1000000UL  /* 1 MHz CPU clock */

#define DELAY 150
#define DELAY_DEBUG 400
#define DELAY_LOOP 700

#define BOOL0 0x01
#define BOOL1 0x02
#define BOOL2 0x04
#define BOOL3 0x08
#define BOOL4 0x10
#define BOOL5 0x20
#define BOOL6 0x40
#define BOOL7 0x80

#include <util/delay.h>
#include <avr/io.h>
#include <math.h>

void blink ( uint8_t output, double delay, uint8_t loop ) {
    uint8_t i = 0;
    while ( ++i <= loop ) {
        PORTC &= ~output;                
        _delay_ms( delay );
        PORTC |= output;
        _delay_ms( delay );
    }
}

void pad_blink ( double delay, uint8_t loop ) {
    blink(_BV(PC0), delay, loop);
}

void debug_blink ( double delay, uint8_t loop ) {
    blink(_BV(PC1), delay, loop);
}

void green_blink ( double delay, uint8_t loop ) {
    blink(_BV(PC2), delay, loop);
}

/*void blink_test ( uint8_t value, uint8_t mask ) {*/
    /*blink ( _DELAY_TEST, ( (value & mask) > 0) );*/
    /*if ( ( value & mask ) > 0 ) {*/
        /*blink(_DELAY_TEST, 1);*/
    /*}*/
    /*_delay_ms( _DELAY_TEST_WAIT );*/
/*}*/

void assign_col ( uint8_t line, uint8_t *v0, uint8_t *v1, uint8_t *v2, uint8_t *v3 ) {
    PORTD = line;
    if ( (PIND & BOOL1) > 0 ) {
        *v0=1;
        /*green_blink( 50, 1 );*/
    }
    if ( (PIND & BOOL6) > 0 ) {
        *v1=1;
        /*debug_blink( 50, 1 );*/
    }
    if ( (PIND & BOOL5) > 0 ) {
        *v2=1;
        /*pad_blink( 50, 1 );*/
    }
    if ( (PIND & BOOL3) > 0 ) {
        *v3=1;
        /*pad_blink( 50, 1 );*/
        /*debug_blink( 50, 1 );*/
    }
}

uint8_t mkdual ( uint8_t exp )
{
    return (exp > 0 ? 1 : 0);
}

int main (void)
{
    /* Declare needs */
    uint8_t k0, k1, k2, k3, k4, k5, k6, k7, k8, k9, kst, ksh, isum;
    /* XXX: store 2 values into single int8 */
    uint8_t kpadv[KEYPAD_LEN];
    uint8_t it = 0, it2 = 0, sum = 0;

    /* configure digital output */
    DDRD = 0x00;
    DDRC = (BOOL0|BOOL1|BOOL2);
    DDRD = (BOOL0|BOOL4|BOOL7);

    /* init state */
    PORTD = 0x00;
    PORTC = (BOOL0|BOOL1|BOOL2);
   
    /* led test */
    debug_blink(50, 2);
    pad_blink(50, 2);
    green_blink(50, 2);
    
    while ( 1 ) /* atom-rocket program, no need to abort */
    {
        kpadv[0] = 0;
        kpadv[1] = 0;
        kpadv[2] = 0;
        sum = 0;
        it2 = 0;
        while ( it < KEYPAD_LEN )
        {
            k0=0; k1=0; k2=0; k3=0; k4=0; k5=0; k6=0; k7=0; k8=0; k9=0; kst=0; ksh=0;
            
            PORTD = (BOOL3|BOOL4|BOOL7);
            while ( ( PIND & (BOOL1|BOOL3|BOOL5|BOOL6) ) == 0 ) {
                _delay_ms(10);
            }

            assign_col ( BOOL7, &k1, &k4, &k7, &kst );
            assign_col ( BOOL0, &k2, &k5, &k8, &k0 );
            assign_col ( BOOL4, &k3, &k6, &k9, &ksh );

            PORTD = (BOOL3|BOOL4|BOOL7);
            while ( ( PIND & (BOOL1|BOOL3|BOOL5|BOOL6) ) > 0 ) {
                _delay_ms(10);
            }
            
            /* notify that key was recognized */
            green_blink(50, 1);

            isum = k1+(k2*2)+(k3*3)+(k4*4)+(k5*5)+(k6*6)+(k7*7)+(k8*8)+(k9*9);

            kpadv[it] = isum;
            ++it;

            _delay_ms(300);
            debug_blink(DELAY_DEBUG, isum);
        }

        /* Lets notify that input was recognized */
        green_blink(50, 2);

        while ( it > 0 ) {
            sum += kpadv[it2] * pow(10, it-1);
            --it;
        }
        
        /*pad_blink(DELAY, sum );*/
        _delay_ms(300);

        /*blink_test ( PIND, BOOL1 );*/
        /*blink_test ( PIND, BOOL3 );*/
        /*blink_test ( PIND, BOOL5 );*/
        /*blink_test ( PIND, BOOL6 );*/

        /*green_blink(1000, 1);*/
    }

    return 0;
}

