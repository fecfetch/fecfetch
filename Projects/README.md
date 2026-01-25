# My Projects

Here are some of the projects I've worked on.

## [Damn Vulnerable MCP Server -  Improvements](Updated-damn-vulnerable-MCP-server)

This is a fork of the [Damn Vulnerable MCP Server (DVMCP)](https://github.com/mrrfv/dvmcp) project, an educational security testing environment for the Model Context Protocol (MCP). The original project provides intentionally vulnerable MCP servers to help developers understand and test for security issues in AI agent integrations.

### [My Contributions & Improvements](Updated-damn-vulnerable-MCP-server/CHANGES.md)
- **Fixed SSE/Regular Server Inconsistencies**: Resolved critical issues where SSE server versions had different vulnerabilities than their regular counterparts, ensuring consistent learning experiences across all server implementations.
- **Enhanced Realism**: Improved Challenge 4 (Rug Pull Attack) and Challenge 5 (Tool Shadowing) by adding missing resource access tools and removing unrealistic implementation patterns that don't exist in actual MCP environments.
- **Architectural Fixes**: Corrected structural issues in multiple challenges, including improper server class implementations and import failures.
- **Complete Exploit Chains**: Made vulnerabilities fully demonstrable by ensuring all necessary tools are present for complete attack scenarios.

These improvements ensure the project accurately reflects real-world MCP security concerns and provides a more effective educational resource for developers learning about AI security.

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

"Word Chef," a word puzzle game designed to help users learn and practice new languages. In this project, I have utilized a range of mobile development skills and the integration of various packages to create a feature-rich application.

The development process was accelerated with the help of AI, particularly in designing the multilingual level generation system.

### Core Technologies & Features
-   **Framework**: Built with Flutter for a cross-platform experience on Android and iOS.
-   **State Management**: Implemented using the `provider` package for scalable and maintainable state management.
-   **Level Generation**: A custom, multilingual level generation system was developed using Dart and Python scripts with AI assistance to create a diverse and engaging learning experience.
-   **Text-to-Speech**: Integrated `flutter_tts` to provide audio pronunciation of words, enhancing the learning process.
-   **Background Processing**: Used `workmanager` to handle background tasks, ensuring a smooth user experience.
-   **Monetization**: Incorporated `google_mobile_ads` for displaying ads.
-   **User Engagement**: Implemented `in_app_review` to prompt users for feedback and `flutter_local_notifications` for notifications.
-   **Device Integration**: Utilized `shared_preferences` for local data persistence, `audioplayers` for sound effects, and `permission_handler` for managing device permissions.


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

This fork maintains the core functionality of the original project while adding a few quality of life functionality such as choosing the message ID and scanning through the messages quicker with automatic scan speed adjustments.

## [Python Games](Python)

A collection of classic games developed using Python and the Pygame library.

### Connect Four
A two-player implementation of the classic game Connect Four with a graphical user interface.

### Snake
The timeless Snake game where the player controls a snake to eat food and grow longer, with adjustable speed.

