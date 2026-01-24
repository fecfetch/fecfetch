# My Projects

Here are some of the projects I've worked on.

## [Thesis: PLC-Based Object Sorting with Image Processing](Thesis%20-%20PLC+Object%20Detection)

This Bachelor's thesis project is a modular automation system that sorts objects on a conveyor belt based on their shape and color. The system integrates image processing with a Programmable Logic Controller (PLC) to create an efficient sorting solution for factory environments.

### System Workflow
1.  **Object Detection**: A camera captures images of objects on a conveyor belt.
2.  **Image Processing**: A C# application using the AForge.NET library identifies the shape and color of each object.
3.  **PLC Communication**: The C# application sends a signal to a Siemens S7-1200 PLC.
4.  **Sorting**: The PLC executes a program (developed in TIA Portal) to activate motors that direct the objects into the correct sorting bins.

### Core Technologies
-   **PLC**: Siemens S7-1200 programmed with TIA Portal.
-   **Image Processing**: C# with the AForge.NET library.
-   **Communication**: Profinet for PLC-PC communication.

## [Language Learning Game](Language%20Learning%20Game)

A word puzzle game, "Word Chef," built with Flutter, designed to help users practice and learn languages.

### Gameplay
Players form words by connecting letters arranged in a circle. The goal is to find all the target words in each level to progress through a series of worlds and sub-worlds.

### Key Features
- **Drag-to-Connect**: An intuitive way to form words by dragging a finger across the letters.
- **Progression System**: The game is structured into 7 worlds, each with multiple sub-worlds and levels.
- **Hint and Shuffle**: Players can use in-game currency to get hints or shuffle the letters.
- **State Management**: Uses the Provider pattern for robust state management.
- **Local Storage**: Saves game progress using `shared_preferences`.

## [Polarization in Communication Channels](Polarization_in_Communication_Channel_Models)

A university presentation from Kiel University that investigates the role of antenna polarization in communication channel models. This research project compares the performance of Spatial Channel Models (SCM) using both cross-polarized and single-polarized antenna arrays.

### Key Areas Covered
- **Channel Modeling**: An overview of fundamental communication channel concepts and models like SCM, SCM-E, and WINNER.
- **Polarization**: Discussion on the principles of polarization and its significance in wireless communications.
- **Simulation**: A MATLAB-based simulation to model and compare the channel capacity of different polarization setups.
- **Presentation**: The findings are compiled in a presentation created with LaTeX (Beamer).

## [Arduino Projects](Arduino)

A collection of projects developed for the Arduino platform.

### [LED Blink via SMS](Arduino/LED_Blink_via_SMS)
This project uses a SIM800L GSM module to control an LED by sending SMS messages.
- Send `#ac` to turn the LED on.
- Send `#kapat` to turn the LED off.
The device sends a confirmation SMS back to the user.

### [Home Automation System](Arduino/Home%20Automation%20System)
A comprehensive home automation system with multiple modes, controlled via Bluetooth.
- **Automatic Mode**: Manages lights based on ambient light levels (LDR), a fan based on temperature, and a water pump based on a water level sensor.
- **Remote Mode**: Allows direct control of all connected devices (LEDs, fan, pump) via Bluetooth commands.
- **Alarm Mode**: Activates a buzzer and an LED when motion is detected.

## [Matkap Fork](0x6rss-matkap-fork)

This is a fork of the [Matkap](https://github.com/0x6rss/matkap) project, a tool for hunting down malicious Telegram bots. Matkap is designed to help cybersecurity professionals analyze and understand Telegram bot interactions.

### Features
- **FOFA & URLScan Integration**: Searches for leaked Bot Tokens / Chat IDs on websites.
- **Export Logs**: Export hunt logs for further analysis.

This fork maintains the core functionality of the original project while allowing for personal modifications and contributions.

## [Python Games](Python)

A collection of classic games developed using Python and the Pygame library.

### Connect Four
A two-player implementation of the classic game Connect Four with a graphical user interface.

### Snake
The timeless Snake game where the player controls a snake to eat food and grow longer, with adjustable speed.

