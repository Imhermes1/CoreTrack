import SwiftUI

// MARK: - Liquid Glass Integration Example
/// This view demonstrates how to integrate the new Liquid Glass components
/// into the existing CoreTrack app structure.
struct LiquidGlassIntegrationExample: View {
    @State private var selectedTab: NavigationTab?
    @State private var inputText = ""
    @State private var showDemo = false
    
    // Sample navigation tabs for the Liquid Glass navbar
    private let liquidGlassTabs = [
        NavigationTab(title: "Home", icon: "house.fill", color: .blue) {
            LiquidGlassHomeView()
        },
        NavigationTab(title: "Coach", icon: "brain.head.profile", color: .green) {
            LiquidGlassCoachView()
        },
        NavigationTab(title: "Analytics", icon: "chart.line.uptrend.xyaxis", color: .orange) {
            LiquidGlassAnalyticsView()
        },
        NavigationTab(title: "Settings", icon: "gear", color: .purple) {
            LiquidGlassSettingsView()
        }
    ]
    
    // Sample quick actions for the input bar
    private let quickActions = [
        QuickAction(title: "Add Food", icon: "plus.circle", color: .blue) {
            print("Add Food action tapped")
        },
        QuickAction(title: "Take Photo", icon: "camera", color: .green) {
            print("Take Photo action tapped")
        },
        QuickAction(title: "Voice Input", icon: "mic", color: .orange) {
            print("Voice Input action tapped")
        },
        QuickAction(title: "Scan Barcode", icon: "barcode.viewfinder", color: .purple) {
            print("Scan Barcode action tapped")
        }
    ]
    
    var body: some View {
        ZStack {
            // Background gradient similar to existing app
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation area with Liquid Glass navbar icon
                HStack {
                    Spacer()
                    
                    LiquidGlassNavbarIcon(
                        tabs: liquidGlassTabs,
                        selectedTab: $selectedTab
                    ) { tab in
                        print("Liquid Glass tab selected: \(tab.title)")
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                
                // Main content area
                if let view = selectedTab?.view {
                    view
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab?.id)
                } else {
                    // Default welcome view
                    LiquidGlassWelcomeView()
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Liquid Glass input bar
                LiquidGlassInputBar(
                    text: $inputText,
                    placeholder: "Add food or ask your AI coach...",
                    quickActions: quickActions,
                    onSend: { message in
                        print("Message sent via Liquid Glass input: \(message)")
                        inputText = ""
                    },
                    onMicTap: {
                        print("Liquid Glass mic tapped")
                    },
                    onCameraTap: {
                        print("Liquid Glass camera tapped")
                    }
                )
                .padding(.bottom, 34) // Safe area
            }
        }
        .onAppear {
            // Set initial tab
            if selectedTab == nil {
                selectedTab = liquidGlassTabs.first
            }
        }
    }
}

// MARK: - Liquid Glass Content Views

struct LiquidGlassWelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Liquid Glass icon
            ZStack {
                if #available(iOS 26.0, *) {
                    Circle()
                        .fill(.clear)
                        .glassEffect(
                            isInteractive: true,
                            shape: Circle()
                        )
                        .frame(width: 120, height: 120)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                }
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("Liquid Glass Components")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Experience iOS 26's new Liquid Glass APIs")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Feature highlights
            VStack(spacing: 16) {
                FeatureRow(icon: "rectangle.stack", title: "Morphing Navbar", description: "Tap the icon to explore navigation")
                FeatureRow(icon: "message.bubble", title: "Glass Input Bar", description: "Type messages with quick actions")
                FeatureRow(icon: "sparkles", title: "Liquid Effects", description: "Smooth animations and transitions")
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

struct LiquidGlassHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's summary card
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(.blue)
                            Text("Today's Summary")
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("1,847")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("85g")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Protein")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("12")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Foods")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Recent foods
                ForEach(1...3, id: \.self) { index in
                    GlassCard {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.green)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Food Item \(index)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("\(200 + index * 50) calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("2:\(index * 10) PM")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct LiquidGlassCoachView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // AI Coach card
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                            Text("AI Coach")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Text("Your AI nutrition coach is ready to help you achieve your health goals. Ask questions, get meal suggestions, or track your progress.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Start Chat") {
                            print("Start AI coach chat")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
                
                // Quick tips
                ForEach(["Stay hydrated", "Eat more protein", "Get enough sleep"], id: \.self) { tip in
                    GlassCard {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text(tip)
                                .font(.body)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct LiquidGlassAnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Analytics overview
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.orange)
                            Text("Weekly Analytics")
                                .font(.headline)
                            Spacer()
                        }
                        
                        // Mock chart placeholder
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .frame(height: 120)
                            .overlay(
                                Text("📊 Chart Placeholder")
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                .padding(.horizontal)
                
                // Stats cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    GlassCard {
                        VStack {
                            Text("12,450")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Total Calories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    GlassCard {
                        VStack {
                            Text("7")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Days Tracked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct LiquidGlassSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(["Profile", "Notifications", "Privacy", "Data & Storage", "About"], id: \.self) { setting in
                    GlassCard {
                        HStack {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                            Text(setting)
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct LiquidGlassIntegrationExample_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassIntegrationExample()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 15 Pro")
    }
}
#endif