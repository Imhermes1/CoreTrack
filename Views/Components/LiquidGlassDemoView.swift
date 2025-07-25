import SwiftUI

// MARK: - Liquid Glass Demo View
struct LiquidGlassDemoView: View {
    @State private var selectedTab: NavigationTab?
    @State private var inputText = ""
    @State private var messages: [DemoMessage] = []
    @State private var currentView: AnyView?
    
    // Sample navigation tabs
    private let navigationTabs = [
        NavigationTab(title: "Home", icon: "house.fill", color: .blue) {
            HomeDemoView()
        },
        NavigationTab(title: "Messages", icon: "message.fill", color: .green) {
            MessagesDemoView(messages: $messages)
        },
        NavigationTab(title: "Settings", icon: "gear", color: .orange) {
            SettingsDemoView()
        },
        NavigationTab(title: "Profile", icon: "person.fill", color: .purple) {
            ProfileDemoView()
        }
    ]
    
    // Sample quick actions
    private let quickActions = [
        QuickAction(title: "Photo", icon: "photo", color: .blue) {
            print("Photo action tapped")
        },
        QuickAction(title: "Document", icon: "doc", color: .green) {
            print("Document action tapped")
        },
        QuickAction(title: "Location", icon: "location", color: .orange) {
            print("Location action tapped")
        },
        QuickAction(title: "Contact", icon: "person.crop.circle", color: .purple) {
            print("Contact action tapped")
        }
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation area
                HStack {
                    Spacer()
                    
                    // Liquid Glass Navbar Icon
                    LiquidGlassNavbarIcon(
                        tabs: navigationTabs,
                        selectedTab: $selectedTab
                    ) { tab in
                        currentView = tab.view
                        print("Selected tab: \(tab.title)")
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                
                // Main content area
                if let view = currentView {
                    view
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab?.id)
                } else {
                    // Default welcome view
                    WelcomeDemoView()
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Liquid Glass Input Bar
                LiquidGlassInputBar(
                    text: $inputText,
                    placeholder: "Type a message...",
                    quickActions: quickActions,
                    onSend: { message in
                        let newMessage = DemoMessage(
                            text: message,
                            isFromUser: true,
                            timestamp: Date()
                        )
                        messages.append(newMessage)
                        inputText = ""
                        print("Message sent: \(message)")
                    },
                    onMicTap: {
                        print("Microphone tapped")
                    },
                    onCameraTap: {
                        print("Camera tapped")
                    }
                )
                .padding(.bottom, 34) // Safe area
            }
        }
        .onAppear {
            // Set initial tab and view
            if selectedTab == nil {
                selectedTab = navigationTabs.first
                currentView = navigationTabs.first?.view
            }
        }
    }
}

// MARK: - Demo Message Model
struct DemoMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Demo Views
struct WelcomeDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome to Liquid Glass")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Tap the icon in the top-right to explore navigation")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

struct HomeDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(1...5, id: \.self) { index in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Home Item \(index)")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Text("This is a sample home item with Liquid Glass styling. The card uses the glass effect for a modern iOS 26 appearance.")
                                .font(.body)
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

struct MessagesDemoView: View {
    @Binding var messages: [DemoMessage]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    MessageBubble(message: message)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct MessageBubble: View {
    let message: DemoMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            GlassCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}

struct SettingsDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(["General", "Privacy", "Notifications", "Appearance", "About"], id: \.self) { setting in
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

struct ProfileDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                GlassCard {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Demo User")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("iOS 26 Liquid Glass Demo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Profile stats
                HStack(spacing: 16) {
                    GlassCard {
                        VStack {
                            Text("42")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Messages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    GlassCard {
                        VStack {
                            Text("156")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    GlassCard {
                        VStack {
                            Text("89")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Friends")
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

// MARK: - Preview
#if DEBUG
struct LiquidGlassDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassDemoView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 15 Pro")
    }
}
#endif