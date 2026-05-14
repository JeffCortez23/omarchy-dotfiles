#include <Servo.h>

// Crear objetos de servo
Servo servoBase;
Servo servoBrazo1;
Servo servoBrazo2;
Servo servoPinza;

// Pines de los servos
const int pinServoBase = 9;
const int pinServoBrazo1 = 10;
const int pinServoBrazo2 = 11;
const int pinServoPinza = 12;

// Pines del joystick
const int joyX1 = A0;
const int joyY1 = A1;
const int joyX2 = A2;
const int joyY2 = A3;

void setup() {
  // Asignar pines a los servos
  servoBase.attach(pinServoBase);
  servoBrazo1.attach(pinServoBrazo1);
  servoBrazo2.attach(pinServoBrazo2);
  servoPinza.attach(pinServoPinza);
  
  // Inicializar servos en posición media
  servoBase.write(90);
  servoBrazo1.write(90);
  servoBrazo2.write(90);
  servoPinza.write(90);

  // Iniciar comunicación serial para depuración
  Serial.begin(9600);
}

void loop() {
  // Leer valores de los joysticks
  int valX1 = analogRead(joyX1);
  int valY1 = analogRead(joyY1);
  int valX2 = analogRead(joyX2);
  int valY2 = analogRead(joyY2);

  // Mapear valores del joystick a ángulos de servo (0-180)
  int angleBase = map(valX1, 0, 1023, 0, 180);
  int angleBrazo1 = map(valY1, 0, 1023, 0, 180);
  int angleBrazo2 = map(valX2, 0, 1023, 0, 180);
  int anglePinza = map(valY2, 0, 1023, 0, 180);

  // Mover servos a las posiciones determinadas
  servoBase.write(angleBase);
  servoBrazo1.write(angleBrazo1);
  servoBrazo2.write(angleBrazo2);
  servoPinza.write(anglePinza);

  // Imprimir valores para depuración
  Serial.print("Base: ");
  Serial.print(angleBase);
  Serial.print("\tBrazo1: ");
  Serial.print(angleBrazo1);
  Serial.print("\tBrazo2: ");
  Serial.print(angleBrazo2);
  Serial.print("\tPinza: ");
  Serial.println(anglePinza);

  // Esperar un pequeño intervalo antes de la siguiente lectura
  delay(15);
}
