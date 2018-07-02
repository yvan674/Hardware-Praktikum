// declare variables
long count;
long startTime;
long endTime;
long startTimeCount;
long endTimeCount;
long totalTime;

void setPin12(boolean high) {
	// pin 12 = PB4
  
  if (high) {
    PORTB |= (1 << 4);
  }
  else {
    PORTB &= ~(1 << 4);
  }
  // result: 326 ms to run it 100.000 times
}

void setPin12ASM(boolean high) {
	if (high) {
		asm volatile (
		"sbi %0, %1\n" // turns it on!
		:: "I" (_SFR_IO_ADDR(PORTB)), "I" (PORTB4) // sets %0 to PORTB, %1, PORTB4
		);
	} else {
		asm volatile (
		"cbi %0, %1\n" // turns it off!
		:: "I" (_SFR_IO_ADDR(PORTB)), "I" (PORTB4) // sets %0 to PORTB, %1, PORTB4
		);
	}
	// result: 51 ms to run it 100.000 times
}

void setup(){
	// for counting the time of setPin12
	count = 0;
	startTime = millis();
	while (count <= 100000) {
		setPin12(false);
		setPin12(true);
		count += 1;
	}
	endTime = millis();
	
	// to compensate for the adding of count in each loop cycle
	count = 0;
	startTimeCount = millis();
	while (count <= 100000) {
		count+= 1;
	}
	endTimeCount = millis();

	// total time of setPin12() * 100.000:
	totalTime = (endTime - startTime) - (endTimeCount - startTimeCount);
	
	// print the totalTime to serial
	Serial.print(totalTime);
	
	// again with setPin12ASM():
	count = 0;
	startTime = millis();
	while (count <= 100000) {
		setPin12ASM(false);
		setPin12ASM(true);
		count += 1;
	}
	endTime = millis();
	
	// total time of setPin12ASM() * 100.000
	totalTime = (endTime - startTime) - (endTimeCount - startTimeCount);
	
	// print the totalTime to serial
	Serial.print(totalTime);
}

void loop(){

}
