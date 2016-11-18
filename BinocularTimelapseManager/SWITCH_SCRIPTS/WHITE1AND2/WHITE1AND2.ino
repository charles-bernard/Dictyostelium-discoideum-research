const int white1 = 3;
const int white1 = 11;

void setup() {
  pinMode(white1, OUTPUT);
  pinMode(white2, OUTPUT);
}

void loop() {
  analogWrite(white1, 20);
  analogWrite(white2, 20);
}
