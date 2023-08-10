## CustomFallbackGenerator :pencil2:

`CustomFallbackGenerator` is a utility class utilized to create fonts with a custom fallback mechanism in your Swift applications. It's designed to ease the management of typography.

### Features :sparkles:

- **Font Generation**: Easily generate fonts based on specific fallback preferences.
- **Customizable**: Choose primary and secondary font options.
- **Size Control**: Select the desired font size.
- **Typography Simplification**: Consolidate font selection into a simple and manageable interface.

### Usage :computer:

```swift
let generator = CustomFallbackGenerator()
let regularFont = generator.font(forFallback: .regular(primary: "Helvetica", secondary: "Arial"), size: 18)
