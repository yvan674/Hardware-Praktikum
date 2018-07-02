// Motor-test

// global variables
int L1 = 10;
int L2 = 11;
bool forward;

// initialization
void setup(){
  // set Motors as output
  pinMode(L1, OUTPUT);
  pinMode(L2, OUTPUT);
  // initiate setMotorSpeed function
  setMotorSpeed(true);
}



void setMotorSpeed(bool forward){
  if (forward == true){
    // forward movement for Left wheel
    digitalWrite(L1, LOW);
    digitalWrite(L2, HIGH); 
  }
  else {
    // backward movement for Left wheel
    digitalWrite(L1, HIGH);
    digitalWrite(L2, LOW);
  }
}


void loop(){
  
}
