# 🎮 Catch & Score

A falling-object collection game written in **assembly language** for the *Computer Organization & Assembly Language (COAL)* course project.

Move your collector left and right to catch valuable falling objects, dodge the dangerous ones, and score as many points as you can in **2 minutes**.

> **Course:** COAL · **Team size:** 2 · **Semester:** Fall 2026

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Game Objects](#-game-objects)
- [Controls](#-controls)
- [Game Rules](#-game-rules)
- [Game Flow](#-game-flow)
- [3×3 Object Representation](#-33-object-representation)
- [Project Phases](#-project-phases)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Team](#-team)

---

## 🧭 Overview

Catch & Score is a falling-object game. Objects fall from the top of the screen. The player controls a collecting object at the bottom and must:

- **Collect** score-giving objects to earn points
- **Avoid** game-ending objects, which end the game instantly
- **Survive** until the 2-minute timer runs out

The project demonstrates core assembly concepts: screen/video output, keyboard input handling, timing, collision detection, modular procedures, and code reuse.

**Reference gameplay:** <https://i.gifer.com/MPBM.gif> (our visuals are our own and do not copy the reference).

---

## ✨ Features

- Dedicated **start screen** with game name, instructions, and *Press Enter to Start*
- **Live score** shown in the top-right corner, updated instantly on every catch
- **2-minute countdown timer** displayed on screen
- Three score-giving object types with different point values
- Game-ending hazard objects that are visually distinct from collectibles
- Smooth left/right movement, kept inside the game boundaries
- **End screen** with the final score
- Every object drawn on a **3×3 grid** representation

---

## 🎯 Game Objects

> Theme: **[Your theme, e.g. Coins → Bucket → Bombs]**

| Category | Object | Points / Effect |
|---|---|---|
| Score-giving (Type 1) | `[e.g. Small coin]` | **+5** |
| Score-giving (Type 2) | `[e.g. Gold coin]` | **+10** |
| Score-giving (Type 3) | `[e.g. Diamond]` | **+15** |
| Collector / Player | `[e.g. Bucket]` | Controlled with arrow keys |
| Game-ending | `[e.g. Bomb]` | **Ends the game immediately** |

---

## ⌨️ Controls

| Key | Action |
|---|---|
| `Enter` | Start the game from the start screen |
| `←` Left Arrow | Move collector left |
| `→` Right Arrow | Move collector right |

---

## 📜 Game Rules

1. **Duration:** each session lasts exactly **2 minutes**. When the timer reaches zero, the game ends automatically and the end screen is shown.
2. **Scoring:** catching a score-giving object adds its points to the live score (5, 10, or 15). The score starts at **0**.
3. **Hazards:** catching a game-ending object ends the game immediately and shows the final score.
4. **Movement:** the collector moves only horizontally and cannot leave the visible game area.
5. **Falling speed:** tuned to be challenging but fair: neither too slow nor impossible to react to.
6. **Respawn:** collected objects disappear/reset and new objects keep falling from the top.

---

## 🔄 Game Flow

```text
START SCREEN
   │  Press Enter
   ▼
GAME STARTS
   ├── Timer starts (2 minutes)
   ├── Score starts from 0
   └── Objects start falling
   │
   ▼
PLAYER MOVES LEFT / RIGHT
   ├── Collect score object  → Increase score
   └── Collect game-ending object → Game ends
   │
   ▼
END SCREEN  (also shown when the 2-minute timer expires)
```

---

## 🔲 3×3 Object Representation

Every game object (collector, score-giving objects, and hazards) is drawn within a **3×3 cell space**. This keeps objects uniformly sized, makes them easy to position, and simplifies collision detection.

```text
Example layout (replace with your own design):

 . X .
 X X X
 . X .
```

<!-- Add screenshots or each object's 3×3 layout here -->

---

## 🗓️ Project Phases

### Phase I: Interface & Objects
**Deadline:** 11:59 pm, Sunday 8 November 2026

- [x] Collector/player object displayed
- [x] Score-giving objects displayed (all 3 types)
- [x] Game-ending object(s) displayed
- [x] 3×3 representation for all objects
- [x] Timer displayed
- [x] Live score displayed
- [x] Start screen (name, instructions, *Press Enter to Start*)
- [x] End screen (game-over message, final score)
- [ ] Complete Phase I Integration Testing
### Phase II: Complete Gameplay
**Deadline:** 11:59 pm, Sunday 29 November 2026

- [ ] Left/right player movement with boundary checks
- [ ] Falling objects (score-giving and game-ending)
- [ ] 5, 10, and 15-point objects
- [ ] Collision/collection detection
- [ ] Live score updates
- [ ] Game-ending object functionality
- [ ] 2-minute gameplay and auto-end
- [ ] Complete, playable game

---

## 🚀 Getting Started

### Prerequisites

- `[Assembler, e.g. MASM / NASM / emu8086]`
- `[Library, e.g. Irvine32 / none]`
- `[Environment, e.g. DOSBox / Visual Studio / Windows]`

### Build & Run

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

# 2. Assemble and link (replace with your toolchain's commands)
[assemble command]
[link command]

# 3. Run
[run command]
```

---

## 📁 Project Structure

```text
.
├── README.md
├── src/
│   └── main.asm          # Entry point / game loop
├── docs/
│   └── screenshots/      # Start screen, gameplay, end screen
└── ...
```

*(Update to match your actual files.)*

---

## 🖼️ Screenshots

| Start Screen | Gameplay | End Screen |
|:---:|:---:|:---:|
| *add image* | *add image* | *add image* |

---

## 👥 Team

| Name | Roll No. | Contribution |
|---|---|---|
| `[Member 1]` | `[Roll No.]` | `[e.g. Graphics, screens]` |
| `[Member 2]` | `[Roll No.]` | `[e.g. Game logic, collisions]` |

---

## 📄 License

This project was developed for academic purposes as part of a university course.
