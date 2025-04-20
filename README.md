A work in progress

# CNY Weather App

A Flutter application that displays weather information for Central New York, featuring real-time temperature data, weather conditions, and historical weather comparisons.

## Features

- **Real-time Weather Data**
  - Current temperature
  - Feels like temperature
  - Weather conditions with icons
  - Last updated timestamp

- **Historical Weather Comparisons**
  - Today's high and low temperatures
  - Yesterday's temperatures
  - Last year's temperatures
  - Record temperatures
  - Average temperatures

- **Weather Details**
  - Wind speed and direction
  - Precipitation information
  - Weather condition icons
  - Detailed weather descriptions

## Technical Details

- Built with Flutter and Dart
- Uses web scraping to fetch weather data from CNYWeather.com
- Implements caching for offline access
- Responsive UI design
- Weather icons support
- ProGuard rules for Android optimization

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Android emulator or physical device for testing

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/trophyguy/CNYWeatherAPP.git
   ```

2. Navigate to the project directory:
   ```bash
   cd CNYWeatherApp
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/`
  - `models/` - Data models and classes
  - `repositories/` - Data fetching and caching logic
  - `screens/` - App screens and navigation
  - `services/` - Background services and utilities
  - `widgets/` - Reusable UI components
  - `main.dart` - App entry point

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Weather data provided by CNYWeather.com
- Flutter team for the amazing framework
- Open source community for various packages and tools
