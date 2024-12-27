# Muhaddil Infections (WIP)

## Description

This FiveM script introduces a disease system that simulates various illnesses with different symptoms, durations, contagion rates, and cures. Players can become infected, experience symptoms, and recover through specific items. The system also supports animations, various effects on players, and a contagion mechanic based on proximity.

## Features

- **Multiple Diseases**: Includes flu, fever, headache, insomnia, nausea, migraine, and cold, each with its own symptoms, animations, and effects.
- **Contagion Mechanic**: Players can spread diseases to others within a specified range.
- **Cure Items**: Each disease can be cured by a specific item, configurable for each illness.
- **Custom Animations**: Diseases trigger specific animations, such as coughing, stumbling, vomiting, etc.
- **Player Effects**: Some diseases slow player movement, cause dizziness, or lead to involuntary falls.
- **ESX or QB Framework Support**: The script supports ESX and QB frameworks.
- **SQL Integration**: Automatically runs the necessary SQL commands if `AutoRunSQL` is enabled.
- **Version Checker**: Automatically checks for script updates.
- **Debug Mode**: Toggleable debug mode for troubleshooting and testing.

## Configuration

### Disease Configuration (in `config.lua`)

Each disease has the following customizable parameters:

- `symptoms`: List of symptoms that players will experience.
- `duration`: The duration of the disease in seconds.
- `contagio`: Contagion rate (0.0 to 1.0, where 1.0 is 100% contagious).
- `rangoContagio`: The range (in meters) within which the disease can spread.
- `cureItem`: The name of the item required to cure the disease.
- `animaciones`: Specific animations that trigger during symptoms.
- `efectos`: Effects on players, such as slow movement, blurry vision, or involuntary actions.

### General Settings

- **`Config.TiempoChequeoContagio`**: Time (in seconds) between contagion checks.
- **`Config.FrameWork`**: Choose between 'esx' or 'qb' frameworks.
- **`Config.AutoRunSQL`**: Automatically runs SQL for necessary database setup.
- **`Config.AutoVersionChecker`**: Enables automatic version checking.
- **`Config.DebugMode`**: Enables debug mode for testing.

## Dependencies

- **ESX or QB Framework**
- **oxmysql** (or **mysql-async** as a commented alternative)
- **ox_lib**: Required library for UI and other functionality

## Installation

1. Download or clone the script into your `resources` folder.
2. Add the resource to your `server.cfg`:

   ```bash
   ensure muhaddil_infections
   ```

3. Ensure the necessary MySQL setup is completed if `AutoRunSQL` is set to `false`.
4. Customize the diseases and settings in the `config.lua` file as needed.
5. Start the server and enjoy the disease and contagion system.

## How it Works

1. When a player contracts a disease, they will begin to exhibit symptoms such as blurry vision, coughing, or stumbling.
2. The disease lasts for the configured duration and may spread to nearby players based on the contagion rate and range.
3. The player can cure the disease using the specified cure item, which will stop the symptoms and effects immediately.
4. The system checks for contagion regularly based on the `TiempoChequeoContagio` setting.

<img src="https://profile-counter.glitch.me/muhaddil_infections/count.svg" alt="Visitor Counter">
