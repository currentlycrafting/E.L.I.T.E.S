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

![Home View](screenshots/home.png)  
*Add players, set rounds, start tournaments.*

![Tournament View](screenshots/tournament.png)  
*Track matches, select winners, and see Elo updates.*

![Leaderboard View](screenshots/leaderboard.png)  
*View rankings dynamically as matches conclude.*

---

## Installation

1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/ELITES.git
