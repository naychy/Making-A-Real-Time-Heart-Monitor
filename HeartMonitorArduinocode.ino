#define USE_ARDUINO_INTERRUPTS true
#include <PulseSensorPlayground.h>

const int PulseWire = A0; 
const int buzzerPin = 8;  // Passive Buzzer(+)
const int ledPin = 13;    // LED(+) 

int Threshold = 344;   

PulseSensorPlayground pulseSensor;
unsigned long beatTime = 0; 
boolean isBeat = false;
boolean beatState = false; 

void setup() {
  Serial.begin(115200); 

  pinMode(buzzerPin, OUTPUT); 
  pinMode(ledPin, OUTPUT); 

  pulseSensor.analogInput(PulseWire);   
  
  if (!pulseSensor.begin()) {
    Serial.println("PulseSensor Error");
    for(;;); 
  }
}

void loop() {
 
  int Signal = pulseSensor.getLatestSample();
  Serial.println(Signal); 


  if (Signal > Threshold && !beatState) {
      tone(buzzerPin, 1000, 50); 
      digitalWrite(ledPin, HIGH); 
      beatTime = millis();           
      isBeat = true;
      beatState = true;
  } 
  
  else if (Signal < Threshold - 2) {
      beatState = false; 
  }

  if (isBeat && (millis() - beatTime > 50)) {
      digitalWrite(ledPin, LOW); 
      isBeat = false;
  }

  delay(20); 
}
