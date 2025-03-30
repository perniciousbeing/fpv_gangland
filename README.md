# FPV_GANGLAND

**FPV_GANGLAND** is a first-person shooter (FPS) game developed in **Lua** using the **ZeroBrane Studio IDE**. Inspired by classic titles like **DOOM**, this game transposes the intense action of gang warfare onto the streets of **Chicago**. Players navigate urban landscapes, engaging in combat with various weapons such as pistols and shotguns.

## Table of Contents

- [Installation](#installation)
- [Gameplay Overview](#gameplay-overview)
  - [Controls](#controls)
  - [Weapons](#weapons)
- [Project Structure](#project-structure)
- [Current Status and To-Do List](#current-status-and-to-do-list)
- [Contributing](#contributing)
- [License](#license)

## Installation

To set up **FPV_GANGLAND** on your local machine:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/perniciousbeing/fpv_gangland.git
   ```
2. **Navigate to the Project Directory:**
   ```bash
   cd fpv_gangland
   ```
3. **Ensure you have the [Love2D](https://love2d.org/) framework installed**, as the game is built upon it.
4. **Run the Game:**
   - Using Love2D:
     ```bash
     love .
     ```
   - Alternatively, if using ZeroBrane Studio:
     - Open the project in ZeroBrane Studio.
     - Run the `main.lua` file.

## Gameplay Overview

### Controls

- **Movement:**
  - `W`: Move forward
  - `S`: Move backward
  - `A`: Strafe left
  - `D`: Strafe right
- **Combat:**
  - `Left Mouse Button`: Fire weapon
  - `Right Mouse Button`: Aim down sights
- **Interaction:**
  - `E`: Interact with objects
- **Miscellaneous:**
  - `R`: Reload weapon
  - `Shift`: Sprint
  - `Esc`: Pause/Menu

*Note: Controls are subject to change as development progresses.*

### Weapons

- **Pistol:**
  - Semi-automatic with moderate damage and range.
- **Shotgun:**
  - High damage at close range with a spread shot.

*Additional weapons may be introduced in future updates.*

## Project Structure

The project's directory is organized as follows:

```
fpv_gangland/
├── engine/
│   ├── [Engine-related Lua scripts]
│   └── ...
├── game/
│   ├── [Game-specific Lua scripts]
│   └── ...
├── conf.lua
├── main.lua
└── README.md
```

- **`engine/`**: Contains core engine scripts handling game mechanics and rendering.
- **`game/`**: Houses scripts specific to game logic, such as player controls and enemy behavior.
- **`conf.lua`**: Configuration file for game settings.
- **`main.lua`**: The main entry point of the game.

## Current Status and To-Do List

### Completed Features

- **Basic Game Engine:** Core mechanics and rendering implemented.
- **Weapon Systems:** Functional pistol and shotgun mechanics coded.

### Pending Tasks

- **Graphics:**
  - Design and integrate sprites for:
    - Player character
    - Enemies
    - Weapons
    - Projectiles
    - Environmental assets (buildings, streets, etc.)
- **Maps:**
  - Create detailed level designs representing Chicago's urban landscape.
  - Implement map loading and transitions.
- **Audio:**
  - Develop sound effects for:
    - Weapon firing and reloading
    - Player actions (footsteps, interactions)
    - Enemy actions
    - Ambient sounds (cityscape, background noise)
  - Compose background music tracks to enhance immersion.
- **Gameplay Enhancements:**
  - Implement enemy AI behaviors.
  - Develop a health and damage system.
  - Introduce mission objectives and storyline elements.
- **User Interface:**
  - Design HUD elements displaying health, ammo count, and objectives.
  - Create menus for game settings, pause, and game over screens.

## Contributing

Contributions are welcome! To contribute:

1. **Fork the Repository.**
2. **Create a New Branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Commit Your Changes:**
   ```bash
   git commit -m "Add your descriptive commit message here"
   ```
4. **Push to Your Fork:**
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Submit a Pull Request.**

Please ensure your contributions align with the project's coding standards and include appropriate documentation.

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this software in accordance with the license terms.
