# iOS 26 Liquid Glass Components

This document provides comprehensive documentation for the modular Liquid Glass components built for iOS 26, following Apple's latest design guidelines and utilizing the new Liquid Glass APIs.

## Overview

The components include:
- **LiquidGlassNavbarIcon**: A morphing icon that expands into a navigation bar
- **LiquidGlassInputBar**: A glassy input bar with text input, mic/camera buttons, and expandable quick actions
- **LiquidGlassDemoView**: A complete demo showcasing both components working together

## Components

### 1. LiquidGlassNavbarIcon

A tappable icon in the top-right that expands into a Liquid Glass overlay navbar with morphing animations.

#### Features
- Morphing icon that changes based on selected tab
- Liquid Glass overlay navbar with smooth transitions
- Support for multiple navigation tabs
- iOS 26 Liquid Glass API integration with fallback support
- Accessibility support

#### Usage

```swift
// Define navigation tabs
let navigationTabs = [
    NavigationTab(title: "Home", icon: "house.fill", color: .blue) {
        HomeView()
    },
    NavigationTab(title: "Messages", icon: "message.fill", color: .green) {
        MessagesView()
    },
    NavigationTab(title: "Settings", icon: "gear", color: .orange) {
        SettingsView()
    }
]

// Use in your view
@State private var selectedTab: NavigationTab?

LiquidGlassNavbarIcon(
    tabs: navigationTabs,
    selectedTab: $selectedTab
) { tab in
    // Handle tab selection
    print("Selected: \(tab.title)")
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `tabs` | `[NavigationTab]` | Array of navigation tabs |
| `selectedTab` | `Binding<NavigationTab?>` | Currently selected tab |
| `onTabSelected` | `(NavigationTab) -> Void` | Callback when tab is selected |

### 2. LiquidGlassInputBar

A beautiful, glassy input bar that mirrors iOS 26 Messages with expandable quick actions.

#### Features
- Liquid Glass styling with morphing transitions
- Expandable text input with dynamic height
- Mic and camera buttons with recording animations
- Expandable "+" quick actions menu
- Send button that appears when text is entered
- iOS 26 Liquid Glass API integration with fallback support

#### Usage

```swift
// Define quick actions
let quickActions = [
    QuickAction(title: "Photo", icon: "photo", color: .blue) {
        // Handle photo action
    },
    QuickAction(title: "Document", icon: "doc", color: .green) {
        // Handle document action
    },
    QuickAction(title: "Location", icon: "location", color: .orange) {
        // Handle location action
    }
]

// Use in your view
@State private var inputText = ""

LiquidGlassInputBar(
    text: $inputText,
    placeholder: "Type a message...",
    quickActions: quickActions,
    onSend: { message in
        // Handle message sending
        print("Message: \(message)")
    },
    onMicTap: {
        // Handle microphone tap
    },
    onCameraTap: {
        // Handle camera tap
    }
)
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `text` | `Binding<String>` | Text input binding |
| `placeholder` | `String` | Placeholder text (default: "Message") |
| `quickActions` | `[QuickAction]` | Array of quick actions |
| `onSend` | `(String) -> Void` | Callback when message is sent |
| `onMicTap` | `() -> Void` | Callback when mic is tapped |
| `onCameraTap` | `() -> Void` | Callback when camera is tapped |

### 3. LiquidGlassDemoView

A complete demo view showcasing both components working together in a realistic app interface.

#### Features
- Complete navigation system with multiple views
- Message interface with chat bubbles
- Profile and settings views
- Real-time message sending and display
- Full Liquid Glass styling throughout

#### Usage

```swift
// Simply present the demo view
LiquidGlassDemoView()
```

## Models

### NavigationTab

Represents a navigation tab with title, icon, color, and associated view.

```swift
struct NavigationTab: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let view: AnyView
}
```

### QuickAction

Represents a quick action with title, icon, color, and action closure.

```swift
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
}
```

## iOS 26 Liquid Glass API Integration

### Available APIs Used

- `glassEffect(isInteractive:shape:)` - Primary Liquid Glass effect
- `glassBackground(displayMode:)` - Background glass effects
- `GlassEffectContainer` - Container for multiple glass effects

### Fallback Support

All components include fallback support for iOS versions prior to 26.0:

```swift
if #available(iOS 26.0, *) {
    // Use Liquid Glass APIs
    .glassEffect(isInteractive: true, shape: RoundedRectangle(cornerRadius: 12))
} else {
    // Fallback to traditional materials
    .background(.ultraThinMaterial)
}
```

## Animation System

### Spring Animations
All animations use spring physics for natural, iOS-like feel:

```swift
.animation(.spring(response: 0.6, dampingFraction: 0.8), value: property)
```

### Morphing Transitions
Icons and elements morph smoothly between states:

```swift
.scaleEffect(iconScale)
.rotationEffect(.degrees(iconRotation))
```

### Overlay Transitions
Navbar and quick actions use asymmetric transitions:

```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 0.8).combined(with: .opacity)
))
```

## Accessibility

### VoiceOver Support
All interactive elements include proper accessibility labels and hints.

### Dynamic Type
Text scales appropriately with system font size settings.

### High Contrast
Components work well in high contrast mode.

## Best Practices

### 1. Performance
- Use `LazyVStack` for large lists
- Minimize view updates during animations
- Use `@State` for local component state

### 2. Design
- Follow Apple's Human Interface Guidelines
- Use consistent spacing and typography
- Ensure proper contrast ratios

### 3. Integration
- Components are modular and reusable
- Support Xcode previews for rapid iteration
- Include comprehensive error handling

## Example Integration

Here's how to integrate both components into your app:

```swift
struct MyAppView: View {
    @State private var selectedTab: NavigationTab?
    @State private var inputText = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], 
                          startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation
                HStack {
                    Spacer()
                    LiquidGlassNavbarIcon(
                        tabs: yourNavigationTabs,
                        selectedTab: $selectedTab
                    ) { tab in
                        // Handle navigation
                    }
                }
                
                // Main content
                if let view = selectedTab?.view {
                    view
                }
                
                Spacer()
                
                // Input bar
                LiquidGlassInputBar(
                    text: $inputText,
                    quickActions: yourQuickActions,
                    onSend: { message in
                        // Handle message
                    }
                )
            }
        }
    }
}
```

## Troubleshooting

### Common Issues

1. **Liquid Glass not appearing**: Ensure you're running iOS 26+ or check fallback implementation
2. **Animations not smooth**: Verify spring animation parameters
3. **Layout issues**: Check safe area insets and padding

### Debug Tips

- Use Xcode previews for rapid iteration
- Test on different device sizes and orientations
- Verify accessibility in VoiceOver mode

## Future Enhancements

- Keyboard handling improvements
- Custom animation curves
- Additional Liquid Glass effects
- Haptic feedback integration
- Dark/light mode optimizations

## Requirements

- iOS 26.0+ for full Liquid Glass features
- iOS 15.0+ for fallback support
- SwiftUI 3.0+
- Xcode 15.0+

## License

These components are designed for educational and development purposes. Follow Apple's guidelines when using in production apps.