# 🥷 Shinobi RPG

A Naruto-inspired text-based MMORPG built with Flutter. Master the art of ninjutsu in this turn-based combat game featuring jutsu abilities, character progression, and immersive ninja theming.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Web browser (Chrome, Firefox, Safari, or Edge)

### Running Locally

#### Option 1: Default Port (Recommended)
```bash
# Navigate to project directory
cd shinobi_rpg

# Run on web with default port
flutter run -d web-server
```
The app will be available at `http://localhost:3000` (or next available port).

#### Option 2: Specific Port
```bash
# Run on a specific port (e.g., port 3000)
flutter run -d web-server --web-port 3000
```
The app will be available at `http://localhost:3000`.

#### Option 3: Chrome Browser
```bash
# Run directly in Chrome browser
flutter run -d chrome --web-port 3000
```

### 🌐 Accessing Your App

Once running, you can access your Shinobi RPG at:
- **Local URL**: `http://localhost:3000`
- **Network URL**: `http://[your-ip]:3000` (for testing on other devices)

### 🔧 Development Tips

- **Consistent Port**: Flutter remembers the last used port, so subsequent runs will use the same port
- **Hot Reload**: Press `r` in the terminal to hot reload changes
- **Hot Restart**: Press `R` in the terminal to hot restart the app
- **Quit**: Press `q` in the terminal to quit the app

### 📱 Features

- **Turn-Based Combat**: Strategic battle system with jutsu abilities
- **Character Progression**: Level up and unlock new abilities
- **Inventory System**: Collect and use items in battle
- **Ninja Theming**: Immersive Naruto-inspired UI and mechanics
- **Save System**: Persistent character data with local storage

## 🛠️ Development

### Project Structure
```
lib/
├── core/                    # Core functionality
│   ├── battle_engine.dart   # Battle system logic
│   └── widgets/             # Reusable UI components
├── models/                  # Data models
├── screens/                 # UI screens
├── services/                # Backend services
└── main.dart               # App entry point
```

### Key Files
- `lib/main.dart` - App entry point
- `lib/screens/main_menu_screen.dart` - Main menu hub
- `lib/screens/battle_screen.dart` - Battle interface
- `lib/core/battle_engine.dart` - Combat logic

## 📚 Getting Started with Flutter

If this is your first Flutter project, check out these resources:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

## 🎮 Game Controls

- **Mouse/Touch**: Click buttons to navigate and interact
- **Keyboard**: Use Tab to navigate between elements
- **Responsive**: Works on desktop and mobile browsers

## 🐛 Troubleshooting

### Port Already in Use
If port 3000 is busy, Flutter will automatically find the next available port (3001, 3002, etc.).

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d web-server --web-port 3000
```

### Browser Compatibility
The app works best in modern browsers:
- Chrome (recommended)
- Firefox
- Safari
- Edge

---

**Version**: 1.0.0  
**Made with**: Flutter & ❤️
