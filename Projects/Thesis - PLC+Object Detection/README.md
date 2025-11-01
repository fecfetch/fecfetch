# Thesis: Modular Object Sorting Automation System with Image Processing

This repository contains the files for my Bachelor's thesis, an automation system that sorts objects on a conveyor belt using image processing and a Programmable Logic Controller (PLC).

## Project Summary

The primary goal of this project is to automate the process of sorting objects based on their shape and color. This system is designed to reduce the need for manual labor in factory settings, thereby increasing efficiency and reducing costs.

### How It Works

1.  **Object Detection:** A standard RGB camera captures images of objects as they move along a conveyor belt.
2.  **Image Processing:** A C# application, utilizing the AForge.NET library, processes these images to identify the shape (square or circle) and color of each object.
3.  **PLC Communication:** Once an object is identified, the C# application sends a corresponding signal to a Siemens S7-1200 PLC.
4.  **Sorting Mechanism:** The PLC, running a program developed in TIA Portal, activates specific motors to control gates that sort the objects into different containers based on the signals received from the C# application.

## Key Technologies

-   **Image Processing:** C#, AForge.NET
-   **PLC Programming:** Siemens TIA Portal, Ladder Logic
-   **Hardware:**
    -   Siemens S7-1200 PLC
    -   24V DC Motors
    -   RGB Camera
    -   Conveyor Belt System
-   **Communication:** Profinet is used for communication between the C# application and the PLC.

## System Components

-   **Mechanical Structure:** A custom-built frame with a conveyor belt and sorting gates.
-   **Control System:** The Siemens S7-1200 PLC at the core of the automation logic.
-   **Vision System:** A C# application for real-time object detection and classification.