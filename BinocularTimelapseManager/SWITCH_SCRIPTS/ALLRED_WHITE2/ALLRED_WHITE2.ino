const int red1 = 5;
const int red2 = 9;
const int red3 = 6;
const int red4 = 10;
const int white2 = 11;

void setup() {
  pinMode(red1, OUTPUT);
  pinMode(red2, OUTPUT);
  pinMode(red3, OUTPUT);  
  pinMode(red4, OUTPUT);
  pinMode(white2, OUTPUT);
}

void loop() {
  analogWrite(red1, 30);
  analogWrite(red2, 30);
  analogWrite(red3, 30);
  analogWrite(red4, 30);
  analogWrite(white2, 20);
}
