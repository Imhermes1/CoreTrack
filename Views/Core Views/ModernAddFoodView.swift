import SwiftUI

@MainActor
struct ModernAddFoodView: View {
    @EnvironmentObject var dataManager: FoodDataManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var aiService: AIService
    @State private var textInput = ""
    @State private var isLoading = false
    
    var body: some View {
        let _ = print("🔄 ModernAddFoodView body rendering")
        return VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Add Food")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Track your meals with AI")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 40)
            
            // Chat area
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(chatManager.messages(for: .food)) { message in
                        ChatBubbleView(message: message)
                    }
                    if isLoading {
                        ChatTypingIndicator()
                    }
                }
                .padding(.horizontal)
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("What did you eat?", text: $textInput)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(shape: RoundedRectangle(cornerRadius: 25))
                    .foregroundColor(.white)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(shape: Circle())
                }
                .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func sendMessage() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        chatManager.addMessage(text: trimmed, sender: .user, to: .food)
        textInput = ""
        isLoading = true
        
        Task {
            do {
                let nutritionData = try await aiService.analyzeFood(input: trimmed, inputType: "text")
                
                await MainActor.run {
                    // Add nutrition data to food entries
                    for item in nutritionData {
                        dataManager.addEntry(FoodEntry(
                            userID: "localUser",
                            timestamp: Date(),
                            description: item.description,
                            calories: item.calories,
                            protein: item.protein,
                            carbs: item.carbs,
                            fat: item.fat,
                            inputMethod: .text
                        ))
                    }
                    
                    // Add confirmation message
                    let totalCalories = nutritionData.reduce(0) { $0 + $1.calories }
                    chatManager.addMessage(
                        text: "Added \(nutritionData.count) food item(s) with \(Int(totalCalories)) calories to your log!",
                        sender: .coach,
                        to: .food
                    )
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    chatManager.addMessage(
                        text: "Sorry, I couldn't analyze that food. Please try again.",
                        sender: .coach,
                        to: .food
                    )
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ModernAddFoodView()
        .environmentObject(FoodDataManager())
        .environmentObject(ChatManager())
        .environmentObject(AIService())
}
