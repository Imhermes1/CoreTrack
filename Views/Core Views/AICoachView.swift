import SwiftUI

@MainActor
struct AICoachView: View {
    @State private var textInput: String = ""
    @State private var isLoading: Bool = false
    @State private var showImagePicker = false
    @State private var pickedImage: UIImage? = nil
    @State private var showDropdown = false
    @State private var lastScrolledMessageID: UUID? = nil
    
    @EnvironmentObject var foodDataManager: FoodDataManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var nutritionService: NutritionService
    @EnvironmentObject var serviceManager: ServiceManager
    
    let onTabChange: (MainViewTab) -> Void

    var body: some View {
        let _ = print("🔄 AICoachView body rendering")
        return VStack(spacing: 0) {
            
            // Quick Actions
            quickActionsView
                .padding(.top, 20)
            
            // Chat area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatManager.messages(for: .coach)) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                        if isLoading {
                            ChatTypingIndicator()
                        }
                        
                        // Live transcription using existing ChatBubbleView style
                        // Live transcription removed - will only show when actively recording
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .onChange(of: chatManager.messages(for: .coach).count) { oldCount, newCount in
                    print("onChange: messages count changed from \(oldCount) to \(newCount)")
                    if let lastMessage = chatManager.messages(for: .coach).last {
                        if lastScrolledMessageID != lastMessage.id {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                            lastScrolledMessageID = lastMessage.id
                        } else {
                            print("Skipping scroll: already at last message")
                        }
                    }
                }

            }
            
            // Styled input bar
            HStack(spacing: 12) {
                // Camera Button
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(shape: Circle())
                }
                // Text input
                TextField("Ask your coach anything...", text: $textInput)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(shape: RoundedRectangle(cornerRadius: 25))
                    .foregroundColor(.white)
                // Mic Button
                Button(action: handleMicButton) {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(shape: Circle())
                }
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(shape: Circle())
                }
                .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 34) // Reduced since no tab bar
            .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    pickedImage = image
                    isLoading = true
                    Task {
                        do {
                            // Analyze the image using AI
                            let nutritionData = try await aiService.analyzeFood(input: "Doctor's slip upload", inputType: "image", image: image)
                            // Add each detected food to the meal log
                            for item in nutritionData {
                                foodDataManager.addEntry(FoodEntry(
                                    userID: "localUser",
                                    timestamp: Date(),
                                    description: item.description,
                                    calories: item.calories,
                                    protein: item.protein,
                                    carbs: item.carbs,
                                    fat: item.fat,
                                    inputMethod: .image,
                                    confidence: 0.8,
                                    sugar: item.sugar,
                                    fibre: item.fibre,
                                    saturatedFat: item.saturatedFat,
                                    sodium: item.sodium,
                                    cholesterol: item.cholesterol
                                ))
                            }
                            await MainActor.run {
                                chatManager.addMessage(text: "Foods from your doctor's slip have been added to your meal log and will be considered in future coaching.", sender: .coach, to: .coach)
                            }
                        } catch {
                            await MainActor.run {
                                chatManager.addMessage(text: "Sorry, I couldn't read the nutritional information from your doctor's slip. Please try again or provide more details.", sender: .coach, to: .coach)
                            }
                        }
                        isLoading = false
                    }
                }
            }
            .onAppear {
                if chatManager.messages(for: .coach).isEmpty {
                    let welcome = "G'day! I'm your AI Nutrition Coach. Ask me anything about your diet!"
                    chatManager.addMessage(text: welcome, sender: .coach, to: .coach)
                }
                // Do NOT request speech permissions on appear - only when user taps mic
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CoachQuickActionButton(
                    title: "Set Goals",
                    icon: "target",
                    action: { handleQuickAction(.setGoals) }
                )
                
                CoachQuickActionButton(
                    title: "Symptoms",
                    icon: "heart.text.square",
                    action: { handleQuickAction(.symptoms) }
                )
                
                CoachQuickActionButton(
                    title: "Meal Plan",
                    icon: "calendar",
                    action: { handleQuickAction(.mealPlan) }
                )
                
                CoachQuickActionButton(
                    title: "Progress",
                    icon: "chart.line.uptrend.xyaxis",
                    action: { handleQuickAction(.progress) }
                )
                
                CoachQuickActionButton(
                    title: "Motivation",
                    icon: "flame",
                    action: { handleQuickAction(.motivation) }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func sendMessage() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        chatManager.addMessage(text: trimmed, sender: .user, to: .coach)
        processUserInput(trimmed)
        textInput = ""
    }
    
    private func processUserInput(_ input: String) {
        isLoading = true
        Task {
            do {
                let chatContext = createChatContext()
                let response = try await aiService.sendMessage(input, context: chatContext)
                await MainActor.run {
                    chatManager.addMessage(text: response, sender: .coach, to: .coach)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    chatManager.addMessage(text: "Sorry, I'm having trouble processing your request. Please try again.", sender: .coach, to: .coach)
                    isLoading = false
                }
            }
        }
    }
    
    private func createChatContext() -> ChatContext {
        let userProfile = UserProfile(
            age: 30,
            weight: 70.0,
            height: 175.0,
            activityLevel: .moderatelyActive,
            dietaryRestrictions: [],
            healthConditions: []
        )
        
        let nutritionGoals = NutritionGoals(
            calorieGoal: 2000,
            proteinGoal: 150,
            carbGoal: 250,
            fatGoal: 65,
            weightGoal: .maintain
        )
        
        return ChatContext(
            userProfile: userProfile,
            conversationHistory: chatManager.messages(for: .coach),
            currentGoals: nutritionGoals
        )
    }
    
    // MARK: - Quick Action Handling
    
    enum QuickActionType {
        case setGoals, symptoms, mealPlan, progress, motivation
    }
    
    private func handleQuickAction(_ actionType: QuickActionType) {
        let userMessage: String
        
        switch actionType {
        case .setGoals:
            userMessage = "Help me set my nutrition goals"
        case .symptoms:
            userMessage = "I want to discuss some symptoms I'm experiencing"
        case .mealPlan:
            userMessage = "Can you create a meal plan for me?"
        case .progress:
            userMessage = "Can you review my progress and give me feedback?"
        case .motivation:
            userMessage = "I need some motivation to stay on track"
        }
        
        // Send as user message and process it normally
        chatManager.addMessage(text: userMessage, sender: .user, to: .coach)
        processUserInput(userMessage)
    }
    
    private func handleMicButton() {
        // Only access speechManager when user actually taps the mic button
        let speechManager = serviceManager.speechManager
        
        if speechManager.permissionStatus != .granted {
            speechManager.requestPermissions()
        } else if speechManager.isRecording {
            speechManager.stopRecording()
            // Handle the speech result
            if !speechManager.lastFinalSpeech.isEmpty {
                chatManager.addMessage(text: speechManager.lastFinalSpeech, sender: .user, to: .coach)
                processUserInput(speechManager.lastFinalSpeech)
                speechManager.lastFinalSpeech = ""
            }
        } else {
            speechManager.startRecording()
        }
    }
}

// MARK: - Quick Action Button

@MainActor
struct CoachQuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(width: 70, height: 60)
            .glassEffect(shape: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
