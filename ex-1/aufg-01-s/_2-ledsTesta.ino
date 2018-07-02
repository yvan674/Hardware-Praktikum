// LED - test : Blinking with 1Hz frequency
// LED is connected to Pin 10

// global variables
int ledPin1 = 10;
int ledPin2 = 11;

// initialization
void setup(){
  // set ledPin as output
  pinMode(ledPin1, OUTPUT);
  pinMode(ledPin1, OUTPUT);
}


void loop(){
  // enable the LED
  digitalWrite(ledPin1, HIGH);
  digitalWrite(ledPin2, LOW);
  // wait for 500ms
  delay(500);
  // disable the LED
  digitalWrite(ledPin1, LOW);
  digitalWrite(ledPin2, HIGH);
  // wait for 500ms
  delay(500);
}
