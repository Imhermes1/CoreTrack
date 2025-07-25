//
//  MainView.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 11/6/2025.
//
import SwiftUI

// MARK: – Glow Overlay for Recording / Response
struct GlowOverlay: View {
    @State private var angle: Double = 0
    let audioLevel: Float
    var isActive: Bool = true

    var body: some View {
        // Red and purple gradient
        let colorStops = [
            Color(red: 1.0, green: 0.1, blue: 0.1), // bright red
            Color(red: 0.8, green: 0.0, blue: 0.8), // purple
            Color(red: 1.0, green: 0.0, blue: 0.0), // pure red
            Color(red: 0.6, green: 0.0, blue: 1.0), // bright purple
            Color(red: 1.0, green: 0.1, blue: 0.1), // bright red
        ]
        let clampedLevel = min(max(audioLevel, 0.01), 0.3)
        let lineWidth = 25 + clampedLevel * 80 // increased base width and range
        let blurRadius = 20 + clampedLevel * 40 // increased blur for more visible effect
        let baseOpacity: Double = isActive ? 1.0 : 0.0 // fully opaque when active

        return RoundedRectangle(cornerRadius: 0)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: colorStops),
                    center: .center,
                    angle: .degrees(angle)
                ),
                lineWidth: CGFloat(lineWidth)
            )
            .blur(radius: CGFloat(blurRadius))
            .opacity(baseOpacity)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }
}

// MARK: - Tab Enum (moved outside for accessibility)
enum MainViewTab: String, CaseIterable {
    case home = "home"
    case coach = "coach"
    case voice = "voice"
    case shop = "shop"
    case analytics = "analytics"
    case more = "more"
}

// MARK: – Main View with Glass Cards and Custom Tab Bar
@MainActor
struct MainView: View {
    @EnvironmentObject var foodDataManager: FoodDataManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var nutritionService: NutritionService
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var serviceManager: ServiceManager
    

    @State private var selectedTab: MainViewTab = .home
    @State private var isVoiceActive: Bool = false
    @State private var addFoodTextInput: String = ""
    @FocusState private var addFoodInputFocused: Bool
    @State private var bottomInset: CGFloat = 0
    
    // MARK: - Computed Properties for Navigation
    
    private var navbarTitle: String {
        switch selectedTab {
        case .home: return "Core Track"
        case .coach: return "AI Coach"
        case .voice: return "Meal Planner"
        case .shop: return "Shopping"
        case .analytics: return "Analytics"
        case .more: return "Settings"
        }
    }
    
    private var navbarSubtitle: String? {
        switch selectedTab {
        case .home: return "AI Food Tracking"
        case .coach: return "Your Nutrition Expert"
        case .voice: return "Smart Meal Planning"
        case .shop: return "Smart Grocery Lists"
        case .analytics: return "Health Insights"
        case .more: return "Preferences"
        }
    }
    
    private var navbarActions: [NavAction] {
        switch selectedTab {
        case .home:
            return [
                NavAction(icon: "plus", color: .white) {
                    NotificationCenter.default.post(name: Notification.Name("showTextInput"), object: nil)
                }
            ]
        case .coach:
            return [
                NavAction(icon: "questionmark.circle", color: .white) {
                    // Help action
                }
            ]
        case .voice:
            return [
                NavAction(icon: "calendar.badge.plus", color: .white) {
                    // Add to calendar action
                }
            ]
        case .shop:
            return [
                NavAction(icon: "cart.badge.plus", color: .white) {
                    // Add to cart action
                }
            ]
        case .analytics:
            return [
                NavAction(icon: "square.and.arrow.up", color: .white) {
                    // Export action  
                }
            ]
        case .more:
            return [
                NavAction(icon: "bell", color: .white) {
                    // Notifications action
                }
            ]
        }
    }

    var body: some View {
        let _ = print("🔄 MainView body rendering - selectedTab: \(selectedTab)")
        return ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onPreferenceChange(HeightKey.self) { height in
                bottomInset = height + 16
            }


            // Glow overlay removed - will only show when recording is active
            
            VStack(spacing: 0) {
                // Simple Navigation Bar (temporary fix)
                HStack {
                    Text(navbarTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Coach") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = .coach
                        }
                    }
                    .foregroundColor(.white)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // Content Area
                switch selectedTab {
                case .home:
                    ModernAddFoodView()
                    
                case .coach:
                    AICoachView(onTabChange: { _ in })
                    
                case .voice:
                    ScrollView {
                        VStack(spacing: 16) {
                            VoiceMealPlannerView()
                            Spacer(minLength: 100)
                        }
                    }
                    
                case .shop:
                    ScrollView {
                        VStack(spacing: 16) {
                            SmartGroceryView()
                            Spacer(minLength: 100)
                        }
                    }
                    
                case .analytics:
                    ScrollView {
                        VStack(spacing: 16) {
                            AnalyticsView()
                            Spacer(minLength: 100)
                        }
                    }
                    
                case .more:
                    ScrollView {
                        VStack(spacing: 16) {
                            SettingsView()
                            Spacer(minLength: 100)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)


        }

    }


}

// MARK: – Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
    }
}

struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

