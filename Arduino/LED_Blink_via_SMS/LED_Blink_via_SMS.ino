#include <SoftwareSerial.h>
#include <Sim800L.h>

SoftwareSerial gsm(2, 3);


#define LED_PIN 12
#define ISIK_PIN 11
#define BEKLE 3
#define RX  10
#define TX  11
String smsMetni = "";
char gelen;
Sim800L GSM(RX, TX);
void SMSgonder(String mesaj) {
  GSM.print("AT+CMGF=1\r");
  delay(100);
  GSM.println("AT+CMGS=\"+905396958419\"");// telefon numarasi degistir
  delay(100);
  GSM.println(mesaj);
  delay(100);
  GSM.println((char)26);
  delay(100);
  GSM.println();
  delay(100);
  GSM.println("AT+CMGD=1,4");
  delay(100);
  GSM.println("AT+CMGF=1");
  delay(100);
  GSM.println("AT+CNMI=1,2,0,0,0");
  delay(200);
  smsMetni = "";
}


void smscoz() {
  while (GSM.available()) {
    delay(BEKLE);
    gelen = GSM.read();
    if (gelen == '#') {
      if (GSM.available()) {
        delay(BEKLE);
        gelen = GSM.read();
        if (gelen == 'a') {
          if (GSM.available()) {
            delay(BEKLE);
            gelen = GSM.read();
       
            if (gelen == 'c') {
      
                      digitalWrite(LED_PIN, HIGH);
                      SMSgonder("LED acildi");
                      Serial.write("acildi");
                    }
    
                    }
                  }
                   else if (gelen == 'k') { if (GSM.available()) {
            delay(BEKLE);
            gelen = GSM.read();
            if (gelen == 'a') {
              if (GSM.available()) {
                delay(BEKLE);
                gelen = GSM.read();
                if (gelen == 'p') {
                  if (GSM.available()) {
                    delay(BEKLE);
                    gelen = GSM.read();
                    if (gelen == 'a') {
                      if (GSM.available()) {
                        delay(BEKLE);
                        gelen = GSM.read();
                        if (gelen == 't') {
                           digitalWrite(LED_PIN, LOW);
                      SMSgonder("LED kapatildi"); 
                          
       
                }
              }
            }
          }
        }
       
                    }
                  }
                }
              }
            }
          }
        }
      }
  

void setup() {

  Serial.begin(19200,SERIAL_8N1);
  GSM.begin(9600);     

  Serial.println("GET PRODUCT INFO: ");
  Serial.println(GSM.getProductInfo());

  Serial.println("GET OPERATORS LIST: ");
  Serial.println(GSM.getOperatorsList());

  Serial.println("GET OPERATOR: ");
  Serial.println(GSM.getOperator());
  pinMode(LED_PIN, OUTPUT);
  pinMode(ISIK_PIN, OUTPUT);
  digitalWrite(ISIK_PIN, HIGH);
  pinMode(7, OUTPUT);
  digitalWrite(7, HIGH);
  delay(3000);
  digitalWrite(7, LOW);

  delay(2000);
  GSM.println("AT+CMGF=1");
  delay(100);
  GSM.println("AT+CNMI=1,2,0,0,0");
  delay(100);
  GSM.println("AT+CMGD=1,4");
  delay(1000);
  SMSgonder("Sistem Acildi");
  GSM.flush();
  delay(100);
}

void loop() {
  smscoz();
  delay(1);
}
