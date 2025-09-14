# E.L.I.T.E.S – Elo-Based Tournament iOS App

**E.L.I.T.E.S** is a lightweight iOS application that allows users to create, manage, and track single-elimination tournaments with Elo-based rankings. Designed using **SwiftUI**, the app features a clean neumorphic interface, persistent storage, and dynamic round progression.  

---

## Features

- **Tournament Management:** Create tournaments with any number of players and track rounds automatically.  
- **Elo Rating System:** Integrated `EloService` to calculate and update player skill ratings after each match.  
- **Neumorphic UI:** Custom buttons, text fields, and choice selectors for a modern and consistent user experience.  
- **Persistent Storage:** Player and match data is saved across app launches using `UserDefaults` and `Codable` models.  
- **Leaderboard:** Real-time leaderboard displays players ranked by Elo.  
- **Round Progression:** Automatic handling of byes and match progression to determine champions.  
- **Responsive Design:** Fully adaptive layout with dynamic validation and real-time feedback.  

---

## Screenshots

![Home View]

<img width="291" height="586" alt="Home" src="https://github.com/user-attachments/assets/291c9abf-514c-463a-9594-396795215494" /> 
*Add players, set rounds, start tournaments.*

![Tournament View]

<img width="318" height="589" alt="Winner" src="https://github.com/user-attachments/assets/3981915a-ad84-4b08-9540-f434af83e3d0" />

*Track matches, select winners, and see Elo updates.*

![Leaderboard View]

<img width="292" height="577" alt="Leaderboard" src="https://github.com/user-attachments/assets/b44d8670-1ee6-4c00-8b80-07bbb6031d68" />

*View rankings dynamically as matches conclude.*

---

## Installation

1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/ELITES.git
