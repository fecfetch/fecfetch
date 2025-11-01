# Arduino Projects

This directory contains a collection of my Arduino-based projects.

## LED Control via SMS

This project uses a SIM800L GSM module to control an LED remotely by sending SMS messages. It's a practical demonstration of IoT capabilities, allowing for the remote control of electronic components.

**Features:**
- Remote control of an LED via SMS.
- Uses the Sim800L GSM module for cellular communication.
- Sends confirmation SMS messages back to the user.

## Home Automation System

This is a comprehensive home automation system that can be controlled via Bluetooth. It integrates various sensors to create an automated and responsive environment.

**Modes of Operation:**
- **Automatic Mode:**
    - Controls LEDs based on a light-dependent resistor (LDR).
    - Manages a fan based on a temperature sensor.
    - Operates a water pump based on a water level sensor.
- **Remote Mode:**
    - Allows for direct manual control of LEDs, the fan, and the water pump through Bluetooth commands.
- **Alarm Mode:**
    - Utilizes a motion sensor to trigger an alarm (LED and buzzer).
    - Continues to manage the water pump for safety.

**Technologies Used:**
- Arduino
- Bluetooth Module
- Temperature Sensor
- Light Dependent Resistor (LDR)
- Water Level Sensor
- Motion Sensor