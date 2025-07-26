//
//  LiquidGlassNavbarIcon.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 26/7/2025.
//

import SwiftUI

// MARK: - Navigation Tab Model
struct NavigationTab: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let content: () -> AnyView
    
    init<V: View>(title: String, icon: String, color: Color, @ViewBuilder content: @escaping () -> V) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = { AnyView(content()) }
    }
    
    static func == (lhs: NavigationTab, rhs: NavigationTab) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Content View Tab Extension
extension ContentViewTab {
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .coach: return "Coach"
        case .voice: return "Voice"
        case .shop: return "Shop"
        case .analytics: return "Analytics"
        case .more: return "More"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .coach: return "brain.head.profile"
        case .voice: return "calendar.badge.plus"
        case .shop: return "cart.badge.plus"
        case .analytics: return "chart.bar.xaxis"
        case .more: return "gear"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .blue
        case .coach: return .green
        case .voice: return .orange
        case .shop: return .red
        case .analytics: return .indigo
        case .more: return .purple
        }
    }
}

// MARK: - Liquid Glass Navbar Icon (Compact with top-left glass button and dropdown)
struct LiquidGlassNavbarIcon<TabType: CaseIterable & RawRepresentable & Hashable>: View where TabType.RawValue == String {
    @Binding var selectedTab: TabType
    let tabs: [TabType]
    let onTabSelected: (TabType) -> Void
    
    @State private var showQuickDropdown = false
    @State private var buttonScale: CGFloat = 1.0
    
    init(selectedTab: Binding<TabType>, tabs: [TabType], onTabSelected: @escaping (TabType) -> Void) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.onTabSelected = onTabSelected
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 12) {
                // Top-left glass button with fork.knife icon to toggle dropdown
                AnyView(
                    Button(action: toggleDropdown) {
                        Image(systemName: "fork.knife")
                            .font(.title3.weight(.medium))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .ifAvailableiOS26 {
                        $0.buttonStyle(.glass)
                    } fallback: {
                        $0.modifier(GlassButtonConditionalStyle(scale: $buttonScale))
                    }
                )
                .overlay(
                    Group {
                        if showQuickDropdown {
                            DropdownNavList(
                                tabs: tabs,
                                selectedTab: $selectedTab,
                                onTabSelected: { tab in
                                    onTabSelected(tab)
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showQuickDropdown = false
                                    }
                                }
                            )
                            .glassEffect()
                            .offset(y: 54)
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                        }
                    },
                    alignment: .topLeading
                )
                .padding(.leading, 16)
                .padding(.top, 10)
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(height: 64)
    }
    
    private func toggleDropdown() {
        withAnimation(.easeOut(duration: 0.1)) {
            buttonScale = 0.95
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6).delay(0.1)) {
            buttonScale = 1.0
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showQuickDropdown.toggle()
        }
    }
}

// MARK: - Nav Tab Bar (vertical bar of glass icon buttons)
private struct NavTabBar<TabType: CaseIterable & RawRepresentable & Hashable>: View where TabType.RawValue == String {
    let tabs: [TabType]
    @Binding var selectedTab: TabType
    let onTabSelected: (TabType) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                    onTabSelected(tab)
                }) {
                    Group {
                        if let contentViewTab = tab as? ContentViewTab {
                            Image(systemName: contentViewTab.iconName)
                                .font(.title3)
                                .foregroundColor(selectedTab == tab ? contentViewTab.color : .white.opacity(0.7))
                        } else {
                            Image(systemName: "questionmark.circle")
                                .font(.title3)
                                .foregroundColor(selectedTab == tab ? .blue : .white.opacity(0.7))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .ifAvailableiOS26 {
                    $0.buttonStyle(.glass)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedTab == tab ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                } fallback: {
                    $0.modifier(GlassButtonConditionalStyle(scale: .constant(1)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedTab == tab ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                }
            }
        }
    }
}

// MARK: - Dropdown Nav List (glass dropdown with all tabs listed tappable)
private struct DropdownNavList<TabType: CaseIterable & RawRepresentable & Hashable>: View where TabType.RawValue == String {
    let tabs: [TabType]
    @Binding var selectedTab: TabType
    let onTabSelected: (TabType) -> Void
    
    private func row(for tab: TabType) -> some View {
        HStack(spacing: 12) {
            if let contentViewTab = tab as? ContentViewTab {
                Image(systemName: contentViewTab.iconName)
                    .foregroundColor(selectedTab == tab ? contentViewTab.color : .white.opacity(0.7))
                    .font(.title3)
                Text(contentViewTab.displayName)
                    .foregroundColor(selectedTab == tab ? contentViewTab.color : .white.opacity(0.7))
            } else {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(selectedTab == tab ? .blue : .white.opacity(0.7))
                    .font(.title3)
                Text(String(describing: tab))
                    .foregroundColor(selectedTab == tab ? .blue : .white.opacity(0.7))
            }
            Spacer()
            if selectedTab == tab {
                Image(systemName: "checkmark")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                VStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { idx in
                        let tab = tabs[idx]
                        tabRow(for: tab, idx: idx)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .glassEffect()
                .frame(minWidth: 180, maxWidth: 280)
            } else {
                // Fallback for earlier iOS versions
                VStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { idx in
                        let tab = tabs[idx]
                        tabRow(for: tab, idx: idx)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .background(.glass)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.white.opacity(0.1), radius: 8, x: 0, y: 0)
                .frame(minWidth: 180, maxWidth: 280)
            }
        }
    }

    @ViewBuilder
    private func tabRow(for tab: TabType, idx: Int) -> some View {
        VStack(spacing: 0) {
            if #available(iOS 26, *) {
                Button(action: {
                    selectedTab = tab
                    onTabSelected(tab)
                }) {
                    row(for: tab)
                }
                .buttonStyle(.glass)
                .background(
                    selectedTab == tab ? Color.white.opacity(0.1) : Color.clear
                )
            } else {
                Button(action: {
                    selectedTab = tab
                    onTabSelected(tab)
                }) {
                    row(for: tab)
                }
                .buttonStyle(GlassButtonStyle(scale: .constant(1)))
                .background(
                    selectedTab == tab ? Color.white.opacity(0.1) : Color.clear
                )
            }
            if idx != tabs.count - 1 {
                Divider()
                    .background(Color.white.opacity(0.1))
            }
        }
    }
}

// MARK: - Glass Button Style (scaling & glass)
struct GlassButtonStyle: ButtonStyle {
    @Binding var scale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: Color.white.opacity(0.1), radius: 6, x: 0, y: 0)
            .scaleEffect(scale)
            .animation(.easeOut(duration: 0.1), value: scale)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    scale = 0.95
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// VisualEffectBlur for iOS 15+ compatibility (wraps UIKit blur)
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

private struct GlassButtonConditionalStyle: ViewModifier {
    @Binding var scale: CGFloat
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(GlassButtonStyle(scale: $scale))
        }
    }
}

// MARK: - View Extension for iOS 26+ conditional modifiers
extension View {
    @ViewBuilder
    func ifAvailableiOS26<Content: View>(@ViewBuilder _ iOS26Plus: (Self) -> Content, fallback: (Self) -> Content) -> some View {
        if #available(iOS 26, *) {
            iOS26Plus(self)
        } else {
            fallback(self)
        }
    }
}

#if DEBUG
struct LiquidGlassNavbarIcon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                LiquidGlassNavbarIcon(
                    selectedTab: .constant(ContentViewTab.home),
                    tabs: Array(ContentViewTab.allCases),
                    onTabSelected: { tab in
                        print("Selected tab: \(tab)")
                    }
                )
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 15 Pro")
    }
}
#endif

