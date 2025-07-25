//
//  SettingsView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var dataManager: FoodDataManager
    @State private var selectedSection: SettingsSection = .account
    
    let onTabChange: (MainViewTab) -> Void
    
    enum SettingsSection: String, CaseIterable {
        case account = "Account"
        case nutrition = "Nutrition"
        case notifications = "Notifications"
        case preferences = "Preferences"
        case data = "Data"
        
        var icon: String {
            switch self {
            case .account: return "person.circle"
            case .nutrition: return "target"
            case .notifications: return "bell"
            case .preferences: return "gear"
            case .data: return "externaldrive"
            }
        }
    }
    
    init(onTabChange: @escaping (MainViewTab) -> Void = { _ in }) {
        self.onTabChange = onTabChange
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                HStack(spacing: 0) {
                    // Sidebar
                    sidebarView
                    
                    // Main content
                    mainContentView
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Customise your experience")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                onTabChange(.home)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var sidebarView: some View {
        VStack(spacing: 8) {
            ForEach(SettingsSection.allCases, id: \.self) { section in
                sidebarButton(for: section)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(width: 200)
        .glassBackground(displayMode: .automatic)
    }
    
    private func sidebarButton(for section: SettingsSection) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedSection = section
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.title3)
                    .foregroundColor(selectedSection == section ? .white : .white.opacity(0.7))
                    .frame(width: 24)
                
                Text(section.rawValue)
                    .font(.body)
                    .fontWeight(selectedSection == section ? .semibold : .medium)
                    .foregroundColor(selectedSection == section ? .white : .white.opacity(0.7))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedSection == section ? Color.white.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch selectedSection {
                case .account:
                    AccountSettingsView()
                case .nutrition:
                    NutritionSettingsView()
                case .notifications:
                    NotificationSettingsView()
                case .preferences:
                    AppPreferencesView()
                case .data:
                    DataManagementView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .glassBackground(displayMode: .automatic)
    }
}

#Preview {
    SettingsView()
        .environmentObject(NotificationManager.shared)
        .environmentObject(FoodDataManager())
} 
