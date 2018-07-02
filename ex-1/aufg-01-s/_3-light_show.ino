// LED - lightshow : Blinking following directions
// Red LED is connected to Pin 10
// Green LED is connected to Pin 12
// Yellow LED is connected to Pin 11

// global variables
int ledPinR = 10;
int ledPinY = 11;
int ledPinG = 12;

// initialization
void setup(){
  // set ledPin as output
  pinMode(ledPinR, OUTPUT);
  pinMode(ledPinG, OUTPUT);
  pinMode(ledPinY, OUTPUT);
}


void loop(){
  // enable the LED
  digitalWrite(ledPinR, HIGH);
  delay(5000);
  digitalWrite(ledPinY, HIGH);
  delay(1000);
  digitalWrite(ledPinR, LOW);
  digitalWrite(ledPinY, LOW);
  digitalWrite(ledPinG, HIGH);
  delay(3000);
  digitalWrite(ledPinG, LOW);
  digitalWrite(ledPinY, HIGH);
  delay(1000);
  digitalWrite(ledPinY, LOW);

}
