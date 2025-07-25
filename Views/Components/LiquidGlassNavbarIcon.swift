import SwiftUI

// MARK: - Navigation Tab Model
struct NavigationTab: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let view: AnyView
    
    init<T: View>(title: String, icon: String, color: Color, @ViewBuilder view: () -> T) {
        self.title = title
        self.icon = icon
        self.color = color
        self.view = AnyView(view())
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NavigationTab, rhs: NavigationTab) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Liquid Glass Navbar Icon
struct LiquidGlassNavbarIcon: View {
    @Binding var selectedTab: NavigationTab?
    @State private var isExpanded = false
    @State private var navbarOffset: CGFloat = 0
    @State private var iconScale: CGFloat = 1.0
    @State private var iconRotation: Double = 0
    
    let tabs: [NavigationTab]
    let onTabSelected: (NavigationTab) -> Void
    
    init(
        tabs: [NavigationTab],
        selectedTab: Binding<NavigationTab?>,
        onTabSelected: @escaping (NavigationTab) -> Void
    ) {
        self.tabs = tabs
        self._selectedTab = selectedTab
        self.onTabSelected = onTabSelected
    }
    
    var body: some View {
        ZStack {
            // Main Icon Button
            Button(action: toggleNavbar) {
                ZStack {
                    // Liquid Glass background for icon
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.clear)
                            .glassEffect(
                                isInteractive: true,
                                shape: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                            .frame(width: 44, height: 44)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 44, height: 44)
                    }
                    
                    // Icon with morphing animation
                    Image(systemName: selectedTab?.icon ?? "pencil")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(selectedTab?.color ?? .blue)
                        .scaleEffect(iconScale)
                        .rotationEffect(.degrees(iconRotation))
                }
            }
            .scaleEffect(iconScale)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: iconScale)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: iconRotation)
            
            // Expanded Navbar Overlay
            if isExpanded {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Navbar Container
                    VStack(spacing: 12) {
                        ForEach(tabs) { tab in
                            NavbarTabButton(
                                tab: tab,
                                isSelected: selectedTab?.id == tab.id,
                                onTap: {
                                    selectTab(tab)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background {
                        if #available(iOS 26.0, *) {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.clear)
                                .glassEffect(
                                    isInteractive: true,
                                    shape: RoundedRectangle(cornerRadius: 20, style: .continuous)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .offset(y: navbarOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: navbarOffset)
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
            }
        }
        .onAppear {
            // Set initial selected tab if none is selected
            if selectedTab == nil && !tabs.isEmpty {
                selectedTab = tabs.first
            }
        }
    }
    
    // MARK: - Private Methods
    private func toggleNavbar() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isExpanded.toggle()
            navbarOffset = isExpanded ? 0 : 50
        }
        
        // Icon animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            iconScale = isExpanded ? 0.9 : 1.0
            iconRotation = isExpanded ? 45 : 0
        }
    }
    
    private func selectTab(_ tab: NavigationTab) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedTab = tab
            iconScale = 1.2
            iconRotation = 0
        }
        
        // Reset icon scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
        }
        
        // Close navbar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toggleNavbar()
        }
        
        onTabSelected(tab)
    }
}

// MARK: - Navbar Tab Button
struct NavbarTabButton: View {
    let tab: NavigationTab
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : tab.color)
                    .frame(width: 24, height: 24)
                
                Text(tab.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tab.color)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview
#if DEBUG
struct LiquidGlassNavbarIcon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    LiquidGlassNavbarIcon(
                        tabs: [
                            NavigationTab(title: "Home", icon: "house.fill", color: .blue) {
                                Text("Home View")
                                    .foregroundColor(.white)
                            },
                            NavigationTab(title: "Messages", icon: "message.fill", color: .green) {
                                Text("Messages View")
                                    .foregroundColor(.white)
                            },
                            NavigationTab(title: "Settings", icon: "gear", color: .orange) {
                                Text("Settings View")
                                    .foregroundColor(.white)
                            }
                        ],
                        selectedTab: .constant(nil)
                    ) { tab in
                        print("Selected tab: \(tab.title)")
                    }
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 15 Pro")
    }
}
#endif