// Motor - test

// global variables
int L1 = 10;
int L2 = 11;
bool forward;
uint8_t spd;

// initialization
void setup(){
  // set Motors as output
  pinMode(L1, OUTPUT);
  pinMode(L2, OUTPUT);
  // initiate setMotorSpeed function
  setMotorSpeed(false,100);
}



void setMotorSpeed(bool forward, uint8_t spd){
  if (forward == true){
    // forward movement of Left wheel at input speed 
    analogWrite(L1, LOW);
    analogWrite(L2, spd); 
  }
  else {
    // backward movement of Left wheel at input speed
    analogWrite(L1, spd);
    analogWrite(L2, LOW);
  }
}



void loop(){
  
}
