// Motor - test

// global variables
int L1 = 10;
int L2 = 11;
int R1 = 9;
int R2 = 6;
bool forward;
uint8_t spd;
int millisec;


// initialization
void setup(){
  // set Motors as output
  pinMode(L1, OUTPUT);
  pinMode(L2, OUTPUT);
  pinMode(R1, OUTPUT);
  pinMode(R2, OUTPUT);
  // initiate driveForward function
  setMotorSpeed(false, 90, R1, R2);
  //driveForward(3000, 60);
}



void setMotorSpeed(bool forward, uint8_t spd, int side1, int side2){
    if (forward == true){
    // forward movement for R/L wheel at input speed  
    analogWrite(side1, LOW);
    analogWrite(side2, spd); 
  }
  else {
    // backward movement of R/L wheel at input speed
    analogWrite(side1, spd);
    analogWrite(side2, LOW);
  }
}



void driveForward(int millisec, uint8_t spd){
  // activate both motors into forward movement and 
  // input speed
  setMotorSpeed(true, spd, R1, R2);
  setMotorSpeed(true, spd, L1, L2);
  // let run for input time
  delay(millisec);
  // turn both motors off
  setMotorSpeed(true, 0, R1, R2);
  setMotorSpeed(true, 0, L1, L2);
  
}

void loop(){
  
}

