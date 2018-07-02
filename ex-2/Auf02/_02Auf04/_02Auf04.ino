//#include <HWPKeypad>

// Motor - test


// global variables
int L1 = 10;
int L2 = 11;
int R1 = 9;
int R2 = 6;
bool forward;
uint8_t spd;
int mSec;


// initialization
void setup(){
  // set Motors as output
  pinMode(L1, OUTPUT);
  pinMode(L2, OUTPUT);
  pinMode(R1, OUTPUT);
  pinMode(R2, OUTPUT);
  // initiate driveCurve function
  //setMotorSpeed(true, 90, L1, L2);
  driveCurve(5000, 90, 90);
}


void setMotorSpeed(bool forward, uint8_t spd, int side1, int side2){
  if (forward == true){
    // forward movement for R/L wheel at input speed
    analogWrite(side1, LOW);
    analogWrite(side2, spd); 
  }
  else {
    // backward movement for R/L wheel at input speed
    analogWrite(side1, spd);
    analogWrite(side2, LOW);
  }

}



void driveForward(int mSec, uint8_t spd){
  // activate both motors into forward movement
  // at input speed
  setMotorSpeed(true, spd, R1, R2);
  setMotorSpeed(true, spd, L1, L2);
  // let run for input time
  delay(mSec);
  // turn both motors off
  setMotorSpeed(true, 0, R1, R2);
  setMotorSpeed(true, 0, L1, L2);
  
}

void driveCurve(int mSec, uint8_t spd, int curve){
  if(curve == 0){
    // activate both motors at same speed for forward movement
    setMotorSpeed(true, spd, R1, R2);
    setMotorSpeed(true, spd, L1, L2);
    // wait given time then turn both off
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
  }
  else if (curve == 90){
    // activate right motor forward at speed and 
    // left motor backward at same speed
    setMotorSpeed(false, spd, R1, R2);
    setMotorSpeed(true, spd, L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
    
  }
  else if (curve == -90){
    // activate left motor forward at speed and 
    // right backward at same speed
    setMotorSpeed(true, spd, R1, R2);
    setMotorSpeed(false, spd, L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
  }
  
  else if (curve == 45){
    // only left motor active forward at 
    // given speed, right motor off
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, spd, L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);  

  }
  else if (curve == -45){
    // only right motor active forward at
    // given speed, left motor off
    setMotorSpeed(true, spd, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
    
    
  }
  else if (curve > 0 && curve < 45){
    // right motor forward at square root 2 over 2
    // times the given speed, left motor forward
    // full speed
    setMotorSpeed(true, spd*(sqrt(2)/2), R1, R2);
    setMotorSpeed(true, spd, L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
  }
  
  else if (curve > 0 && curve > 45){
    // right motor backward at square root 2 over 2
    // times the given speed, left motor 
    // full speed
    setMotorSpeed(false, spd*(sqrt(2)/2), R1, R2);
    setMotorSpeed(true, spd, L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
    
    
  }
  else if (curve < 0 && curve > -45){
    // left motor forward at square root 2 over 2
    // times the given speed, right motor forward
    // full speed
    setMotorSpeed(true, spd, R1, R2);
    setMotorSpeed(true, spd*(sqrt(2)/2), L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
  }
  else if (curve < 0 && curve < -45){
    // left motor backward at square root 2 over 2
    // times the given speed, right motor forward
    // full speed
    setMotorSpeed(true, spd, R1, R2);
    setMotorSpeed(false, spd*(sqrt(2)/2), L1, L2);
    delay(mSec);
    setMotorSpeed(true, 0, R1, R2);
    setMotorSpeed(true, 0, L1, L2);
    
    
  }
}

void loop(){

  
}




