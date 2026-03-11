# Dynamic Island

Dynamic Island like plugin for Noctalia.

## Features

- **Compact view**: Shows album art, track title, and audio visualizer
- **Morphing animation**: Smoothly expands into a full media panel when clicked
- **Media controls**: Play/pause, skip, and progress bar
- **Audio visualizer**: Spring physics visualizer using SpectrumService

## Screenshots

_Coming soon_

## Installation

1. Install via Noctalia's plugin manager (recommended)
2. Or manually clone to `~/.config/noctalia/plugins/dynamic-island/`
3. Enable in Settings → Plugins
4. Add to bar in Settings → Bar → Center section

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| compactWidth | 180 | Width of the island in compact mode |
| expandedTimeout | 5000 | Auto-collapse timeout in ms |
| showVisualizer | true | Show audio visualizer |

## Requirements

- Noctalia 3.6.0+
- cava (for audio visualizer)

## License

MIT

## Credits

- Inspired by Apple's Dynamic Island
- Built for [Noctalia](https://github.com/noctalia-dev/noctalia)
