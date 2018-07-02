// display buttons: write some data to the lcd and 
// shows the button pressed

/* Connections:
 R/S : Pin 3
 R/W : not connected
 E   : Pin 4
 DB4 : Pin 6
 DB5 : Pin 7
 DB6 : Pin 8
 DB7 : Pin 9

 Red LED    : 10
 Yellow LED : 11
 Green LED  : 12
*/

// include LCD functions:
#include <LiquidCrystal.h> 

// define the LCD screen
LiquidCrystal lcd(3, 4, 6, 7, 8, 9);

// global variable, stores the result from analog pin, button, and led pins
int buttonVal;
int button;
const int ledPinR = 10;
const int ledPinY = 11;
const int ledPinG = 12;

// time counter
unsigned long prevMill;

// Ampel state
int state;

void setup()
{
  // LCD has 4 lines with 20 chars
  lcd.begin(20, 4); 
  lcd.print("system ready");
  delay(500);

  // set ledPin as output
  pinMode(ledPinR, OUTPUT);
  pinMode(ledPinG, OUTPUT);
  pinMode(ledPinY, OUTPUT);
  prevMill = 0;
  state = 0;
}


void loop()
{
  // read analogValue
  buttonVal = analogRead(0);
  
  // if statements for buttons
  if(buttonVal > 950){
    button = 0;
  }
  else if(buttonVal > 750 && buttonVal < 950){
    button = 5;
    
  }
  else if(buttonVal > 550 && buttonVal < 750){
    button = 4;
  }
  else if(buttonVal > 350 && buttonVal < 550){
    button = 3;
  }
  else if(buttonVal > 150 && buttonVal < 350){
    button = 2;
  }
  else if(buttonVal < 150){
    button = 1;
  }
  // code for LCD screen:
  lcd.setCursor(0,0);
  lcd.print("Analog 0:       ");
  lcd.setCursor(10, 0);
  lcd.print(buttonVal);
 
  if(button == 0){
    lcd.setCursor(0,1);
    lcd.print("Button: - ");
  }
  else{
    lcd.setCursor(0,1);
    lcd.print("Button: S");
    lcd.setCursor(9,1);
    lcd.print(button);
  }
/*
  // debug
  lcd.setCursor(8,2);
  lcd.print(state);
  lcd.setCursor(0,3);
  lcd.print(millis());
  lcd.setCursor(7,3);
  lcd.print(prevMill);
  lcd.setCursor(14,3);
*/

  // Ampel Program sequence
  if(button == 1 && state == 0){
    prevMill = millis();
    state = 1;
  }

  if(millis() - prevMill >= 1000 && state == 1){
    // start sequence with yellow light
    prevMill = millis();
    state = 2;
  }

  if(millis() - prevMill >= 3000 && state == 2){
    // green light
    prevMill = millis();
    state = 3;
  }
  
  if(millis() - prevMill >= 1000 && state == 3){
    // green --> yellow light
    prevMill = millis();
    state = 0;
  }

  // state colors
  if(state == 0){
    lcd.setCursor(0,2);
    lcd.print("red   ");
    tone(13, 100);
    digitalWrite(ledPinR, HIGH);
    digitalWrite(ledPinY, LOW);
  }
  if(state == 1){
    lcd.setCursor(0,2);
    lcd.print("red and yellow");
    digitalWrite(ledPinY, HIGH);
  }

  if(state == 2){
    lcd.setCursor(0,2);
    lcd.print("green         ");
    tone(13, 400);
    digitalWrite(ledPinR, LOW);
    digitalWrite(ledPinY, LOW);
    digitalWrite(ledPinG, HIGH);
  }
  if(state == 3){
    lcd.setCursor(0,2);
    lcd.print("yellow");
    noTone(13);
    digitalWrite(ledPinG, LOW);
    digitalWrite(ledPinY, HIGH);
  }
}


/* Usefull LCD functions:
set the current write position of the lcd to specific line and row:
  lcd.setCursor(row, line);  

write onto lcd, starting at current position:
  lcd.print("abc");

clear the lcd (this writes " " into all positions and is therefore slow):
If only specific areas should be cleared use a mix of setCursor and print(" ") instead
  lcd.clear();
*/
