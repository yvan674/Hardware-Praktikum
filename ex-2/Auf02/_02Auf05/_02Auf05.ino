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
  driveCurve(1000, 90, 90);
}


void setMotorSpeed(bool forward, uint8_t spd, int side1, int side2){
  //
  if (forward == true){
    // forward movement for R/L wheel
    analogWrite(side1, LOW);
    analogWrite(side2, spd); 
  }
  else {
    // backward movement for R/L wheel
    analogWrite(side1, spd);
    analogWrite(side2, LOW);
  }

}



void driveForward(int mSec, uint8_t spd){
  // activate both motors into forward movement
  setMotorSpeed(true, spd, R1, R2);
  setMotorSpeed(true, spd, L1, L2);
  // let run for given amount of time
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


void shapeMovement() {
    buttonVal = analogRead(0);
    if(buttonVal > 950){
      // does nothing
      drive(0, 0, 0)
  }
  else if(buttonVal > 750 && buttonVal < 950){
      // makes a square shape
      driveCurve(3000, 90, 0);
      driveCurve(780, 90, 90);
      driveCurve(3000, 90, 0);
      driveCurve(780, 90, 90);
      driveCurve(3000, 90, 0);
      driveCurve(780, 90, 90);
      driveCurve(3000, 90, 0);
      driveCurve(780, 90, 90);
    
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

/*void square(){

} */

void loop(){

  
}




