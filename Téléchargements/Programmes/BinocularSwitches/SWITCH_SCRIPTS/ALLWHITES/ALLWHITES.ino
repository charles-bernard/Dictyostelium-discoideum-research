const int white1 = 11;
const int white2 = 3;
const int white3 = 2;

void setup() {
  pinMode(white1, OUTPUT);
  pinMode(white2, OUTPUT);
  pinMode(white3, OUTPUT);
}

void loop() {
  analogWrite(white1, 10);
  analogWrite(white2, 10);
  digitalWrite(white3, HIGH);
}
