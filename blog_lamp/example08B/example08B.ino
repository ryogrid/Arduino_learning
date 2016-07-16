//
// Copy and paste this example into an empty Arduino sketch

#define SENSOR 0   
#define R_LED 9
#define G_LED 10
#define B_LED 11
#define BUTTON 12

int val = 0; // variable to store the value coming from the sensor

int btn = LOW;
int old_btn = LOW;
int state = 0;
char buffer[7] ;
int pointer = 0;
byte inByte = 0;

byte r = 0;
byte g = 0;
byte b = 0;

void setup() {
  Serial.begin(9600);  // open the serial port
  pinMode(BUTTON, INPUT);
}

void loop() {
//  val = analogRead(SENSOR); // read the value from the sensor
                            // the serial port

  if (Serial.available() > 0) {

    // read the incoming byte:
    inByte = Serial.read();

    // If the marker's found, next 6 characters are the colour
    if (inByte == '#') {

      while (pointer > 6) { // accumulate 6 chars
        buffer[pointer] = Serial.read(); // store in the buffer
        pointer++; // move the pointer forward by 1
      }

  
      pointer = 0; // reset the pointer so we can reuse the buffer
     
    }
  }   
//Serial.println(r);      // print the value to

if(inByte == 0){
    analogWrite(R_LED, 255);  // turn the leds on
    analogWrite(B_LED, 255);  // sent by the computer   
}else if(inByte==1){
    analogWrite(R_LED, 255);  // turn the leds on
    analogWrite(B_LED, 0);  // sent by the computer
}else if(inByte==2){
    analogWrite(R_LED, 0);  // turn the leds on
    analogWrite(B_LED, 255);  // sent by the computer
 
}

//    analogWrite(R_LED, 255);  // turn the leds on
//    analogWrite(G_LED, 255);  // at the colour
//    analogWrite(B_LED, 255);  // sent by the computer
 
  delay(100);                // wait 100ms between each send
}

