// declare variables
volatile uint32_t tCount;
uint32_t duration[10] = {500, 600, 800, 1000, 1100, 1300, 
                        1400, 1800, 2000, 2400};
volatile uint32_t sCount = 0;
volatile uint32_t index = 0;
uint32_t frequency[10] = {100, 200, 450, 600, 1050, 1400,
                          1550, 1600, 1800, 1950};

void newfreq(int freq) {
  // changes the frequency of timer2 to a new one by
  // finding new compare register value based on given 
  // input frequency
  int ocrValue;
  ocrValue = 15625 / freq;
  OCR2A = ocrValue;
}

void setup() {
  Serial.begin(38400);
  // sets output pins
  pinMode(12, OUTPUT);
  pinMode(11, OUTPUT);
  /*  100 Hz from 8 MHz
   *  so overflow 200 times per seconds (200 Hz)
   *  set divider at 256
   *  count to 156.25 -> 156
   *  
   *  1000 Hz from 8 MHz
   *  so overflow 2000 times per second (2 KHz)
   *  set divider at 1024
   */

  // disable interupts
  cli();

  // reset control registers
  TCCR2A = 0;
  TCCR2B = 0;
  TCCR1A = 0;
  TCCR1B = 0;
  TCCR1C = 0;

  // set timer 2 clock prescaler : 256
  TCCR2B |= (1 << CS22);
  TCCR2B |= (1 << CS21);

  // set timer 1 clock prescaler : 256
  TCCR1B |= (1 << CS12);

  // setmode timer 2 (CTC)
  TCCR2A |= (1 << WGM21);

  // setmode timer 1 (CTC)
  TCCR1B |= (1 << WGM12);

  // set output compare register A for Timer 2
  OCR2A = 156;

  // set output compare reigster A for Timer 1
  OCR1A = 16;

  // enable interupt
  TIMSK2 |= (1 << OCIE2A);
  TIMSK1 |= (1 << OCIE1A);

  // enable all interrupts
  sei();
}

void loop() {
  
}

ISR(TIMER1_COMPA_vect) {
  boolean pin11On;
  Serial.println(tCount++); // prints tCount to serial
  // Aufgabe 7, 8
  if (tCount >= sCount) {
    if (index == 9) {
      index = 0;
    }
    else {
      index += 1;
    }
    // pin 11 = PB3
    
    if (pin11On) {
      digitalWrite(11, HIGH);
      pin11On = true;
    }
    else {
      digitalWrite(11, LOW);
      pin11On = false;
    }
    newfreq(frequency[index]);
    sCount = tCount + duration[index];
  }
  
}

// interrupt service routine for timer 2 compare match
ISR(TIMER2_COMPA_vect) {
  
  // toggle pin
  PINB |= (1 << 4);
}
