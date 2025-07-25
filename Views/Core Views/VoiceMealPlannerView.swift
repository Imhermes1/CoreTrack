import SwiftUI
import AVFoundation

@MainActor
struct AIMealPlannerView: View {
    // MARK: - Injected Services
    @EnvironmentObject var aiService: AIService

    // MARK: - State
    @State private var goals = ""
    @State private var preferences = ""
    @State private var restrictions = ""
    @State private var timeframe = "1 week"
    @State private var generatedPlan = ""
    @State private var isGenerating = false
    @State private var showingPlan = false

    // MARK: - Constants
    let timeframeOptions = ["3 days", "1 week", "2 weeks", "1 month"]
    let onTabChange: (MainViewTab) -> Void

    // MARK: - Init
    init(onTabChange: @escaping (MainViewTab) -> Void = { _ in }) {
        self.onTabChange = onTabChange
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.green.opacity(0.08), Color.blue.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 30)
            .overlay(Color.white.opacity(0.02).blur(radius: 15))
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    inputForm
                    generateButton
                    generatedPlanView
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 16) {
            Circle()
                .frame(width: 80, height: 80)
                .glassEffect(shape: Circle())
                .overlay(
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 35))
                        .foregroundColor(.orange)
                )

            Text("AI Meal Planner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Let AI create personalised meal plans based on your goals")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var inputForm: some View {
        VStack(spacing: 20) {
            InputCard(
                title: "Your Goals",
                placeholder: "e.g., Lose weight, build muscle, maintain health",
                text: $goals
            )
            InputCard(
                title: "Food Preferences",
                placeholder: "e.g., Mediterranean, vegetarian, high protein",
                text: $preferences
            )
            InputCard(
                title: "Dietary Restrictions",
                placeholder: "e.g., Gluten-free, dairy-free, no nuts",
                text: $restrictions
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Timeframe")
                    .font(.headline)
                    .foregroundColor(.white)

                Picker("Timeframe", selection: $timeframe) {
                    ForEach(timeframeOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }

    private var generateButton: some View {
        Button(action: generateMealPlan) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "sparkles")
                        .font(.title2)
                }

                Text(isGenerating ? "Creating Your Plan..." : "Generate Meal Plan")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(isGenerating || goals.isEmpty)
        .opacity(goals.isEmpty ? 0.6 : 1.0)
    }

    private var generatedPlanView: some View {
        Group {
            if showingPlan && !generatedPlan.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Personalised Meal Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(generatedPlan)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .glassEffect(shape: RoundedRectangle(cornerRadius: 16))
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    // MARK: - Actions

    private func generateMealPlan() {
        guard !goals.isEmpty else { return }

        isGenerating = true
        showingPlan = false

        Task {
            do {
                let mealPreferences = MealPreferences(
                    cuisine: [.australian], // Default to Australian
                    cookingTime: .medium,
                    servings: 2,
                    budget: .moderate
                )
                
                let plan = try await aiService.generateMealPlan(preferences: mealPreferences)
                
                await MainActor.run {
                    generatedPlan = plan.description
                    isGenerating = false
                    showingPlan = true
                }
            } catch {
                await MainActor.run {
                    generatedPlan = "Sorry, I couldn't generate a meal plan. Please try again."
                    isGenerating = false
                    showingPlan = true
                }
            }
        }
    }
}

// MARK: - Input Card Component

@MainActor
struct InputCard: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            TextField(placeholder, text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
        }
        .padding()
        .glassEffect(shape: RoundedRectangle(cornerRadius: 16))
    }
}

// Legacy alias for backwards compatibility
typealias VoiceMealPlannerView = AIMealPlannerView

// MARK: - Preview

struct AIMealPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        AIMealPlannerView()
            .preferredColorScheme(.dark)
    }
}
