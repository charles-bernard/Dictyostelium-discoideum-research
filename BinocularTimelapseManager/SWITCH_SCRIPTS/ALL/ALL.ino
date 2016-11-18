const int red1 = 5;
const int red2 = 9;
const int red3 = 6;
const int red4 = 10;
const int white1 = 11;
const int white2 = 3;
const int white3 = 2;

void setup() {
  pinMode(red1, OUTPUT);
  pinMode(red2, OUTPUT);
  pinMode(red3, OUTPUT);  
  pinMode(red4, OUTPUT);
  pinMode(white1, OUTPUT);
  pinMode(white2, OUTPUT);
  pinMode(white3, OUTPUT);
}

void loop() {
  analogWrite(red1, 100);
  analogWrite(red2, 100);
  analogWrite(red3, 100);
  analogWrite(red4, 100);
  analogWrite(white1, 10);
  analogWrite(white2, 10);
  digitalWrite(white3, HIGH);
}
