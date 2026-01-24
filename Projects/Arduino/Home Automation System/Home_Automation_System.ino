#include <Wire.h>

#include <SoftwareSerial.h>

SoftwareSerial BT(10,11);
const int temp_sensor = 0;
const int fan = 22;
float temp;
int threshold = 21;
const int LDRsensor=1;
const int LED1=6;

const int LED2=7;
const int LED3=8;
const int LED4=9;
int LDRvalue;
const int WL_sensor =15;
const int Wpump = 13;
float water_level;
const int mov_sensor=3;
const int LEDalarm=4;
const int buzzer=5;
int mov_value;
char state;
char mode;
void setup() {

  pinMode(temp_sensor, INPUT);
  pinMode(fan, OUTPUT);
  pinMode(LDRsensor, INPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(WL_sensor, INPUT);
   pinMode(Wpump, OUTPUT);
    pinMode(mov_sensor, INPUT);
     pinMode(LEDalarm, OUTPUT);
     pinMode(buzzer, OUTPUT);
  BT.begin(9600); 
 
}

void loop() {
  if(BT.available()>0)
{state = BT.read();
}
if (state== 'Y')
{mode='A';
}
else if  (state == 'Z')
{ mode = 'R';
}
else if ( state=='X')
{ mode ='D';
}
if (mode == 'A')
{
automaticmode();
}

else if (mode == 'R')
{ 
remotemode();
}

else if (mode == 'D')
{ 
alarmmode();
}
}

void automaticmode()
{
  LDRvalue = analogRead(LDRsensor);
  water_level = analogRead(WL_sensor);
  temp= analogRead(temp_sensor);
  temp= temp*0.4883;

  if (water_level>100)
  { digitalWrite(Wpump, HIGH);
  }
  else
  {  digitalWrite(Wpump, LOW);
 
}
if ((LDRvalue<1023)& (LDRvalue>=822))
{ digitalWrite(LED1, LOW);
digitalWrite(LED2,LOW);
digitalWrite(LED3, LOW);
digitalWrite(LED4,LOW);
}
else if ((LDRvalue<821)& (LDRvalue>=617))
{ digitalWrite(LED1, HIGH);
digitalWrite(LED2,LOW);
digitalWrite(LED3, LOW);
digitalWrite(LED4,LOW);
}
else if ((LDRvalue<616)& (LDRvalue>=412))
{ digitalWrite(LED1, HIGH);
digitalWrite(LED2,HIGH);
digitalWrite(LED3, LOW);
digitalWrite(LED4,LOW);
}
else if ((LDRvalue<411)& (LDRvalue>=207))
{ digitalWrite(LED1, HIGH);
digitalWrite(LED2,HIGH);
digitalWrite(LED3, HIGH);
digitalWrite(LED4,LOW);
}
else if (LDRvalue<206)
{ digitalWrite(LED1, HIGH);
digitalWrite(LED2,HIGH);
digitalWrite(LED3, HIGH);
digitalWrite(LED4,HIGH);
}

if (temp >= threshold)
{ digitalWrite(fan,HIGH);
}
else if (temp< threshold)
{ digitalWrite (fan,LOW);
}
}
void remotemode()
{ digitalWrite (LEDalarm,LOW);
digitalWrite (buzzer,LOW);
if (BT.available()>0)
{
  state=BT.read();
}
if (state =='D')
{ digitalWrite (LED1,LOW);
}
else if (state =='C')
{ digitalWrite (LED1,HIGH);
}
if (state =='F')
{ digitalWrite (LED2,LOW);
}
else if (state =='E')
{ digitalWrite (LED2,HIGH);
}
if (state =='H')
{ digitalWrite (LED3,LOW);
}
else if (state =='G')
{ digitalWrite (LED3,HIGH);
}
if (state =='J')
{ digitalWrite (LED4,LOW);
}
else if (state =='I')
{ digitalWrite (LED4,HIGH);
}
if (state =='B')
{ digitalWrite (LED1,LOW);
digitalWrite (LED2,LOW);
digitalWrite (LED3,LOW);
digitalWrite (LED4,LOW);
}
else if (state =='A')
{ digitalWrite (LED1,HIGH);
digitalWrite (LED2,HIGH);
digitalWrite (LED3,HIGH);
digitalWrite (LED4,HIGH);
}
if (state =='L')
{ digitalWrite (fan,LOW);
}
else if (state =='K')
{ digitalWrite (fan,HIGH);
}
if (state =='N')
{ digitalWrite (Wpump,LOW);
}
else if (state =='M')
{ digitalWrite (Wpump,HIGH);
}
}
void alarmmode()
{
  water_level = analogRead(WL_sensor);
  if (digitalRead(mov_sensor))
  {digitalWrite(LEDalarm,HIGH);
  digitalWrite(buzzer,HIGH);
}
else {digitalWrite(LEDalarm,LOW);
  digitalWrite(buzzer,LOW);
}
if (water_level>100)
{ digitalWrite(Wpump, HIGH);
}
else{ digitalWrite(Wpump, LOW);
}
}
