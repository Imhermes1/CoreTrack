import SwiftUI

struct SmartGroceryView: View {
    let onTabChange: (MainViewTab) -> Void = { _ in }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.orange.opacity(0.08), Color.red.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 30)
            .overlay(Color.white.opacity(0.02).blur(radius: 15))
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Feature Icon
                ZStack {
                    Circle()
                        .frame(width: 120, height: 120)
                        .glassEffect(shape: Circle())
                    
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }
                
                // Title and Description
                VStack(spacing: 16) {
                    Text("Smart Grocery List")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                // Feature Description
                VStack(spacing: 20) {
                    Text("AI-powered grocery shopping with direct food ordering")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        GroceryFeatureRow(
                            icon: "brain.head.profile",
                            title: "Smart Recommendations",
                            description: "AI suggests groceries based on your nutrition goals and eating patterns"
                        )
                        
                        GroceryFeatureRow(
                            icon: "list.bullet.clipboard.fill",
                            title: "Auto Shopping Lists",
                            description: "Generate shopping lists from your meal plans and favourite foods"
                        )
                        
                        GroceryFeatureRow(
                            icon: "storefront.fill",
                            title: "Direct Food Ordering",
                            description: "Order food directly through the app from Coles, Woolworths & local stores"
                        )
                        
                        GroceryFeatureRow(
                            icon: "bicycle",
                            title: "Delivery Integration",
                            description: "Connect with DoorDash, Uber Eats, Menulog for restaurant ordering"
                        )
                        
                        GroceryFeatureRow(
                            icon: "dollarsign.circle.fill",
                            title: "Budget Tracking",
                            description: "Track food spending and find healthy options within your budget"
                        )
                        
                        GroceryFeatureRow(
                            icon: "leaf.fill",
                            title: "Nutrition Optimised",
                            description: "Suggestions prioritise your health goals and dietary requirements"
                        )
                    }
                }
                
                Spacer()
                
                // Special Note about Food Ordering
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Food Ordering Feature")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("Order food directly from the app and automatically track nutrition data")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassEffect(shape: RoundedRectangle(cornerRadius: 16))
                
                // Coming Soon Badge
                HStack {
                    Image(systemName: "clock.badge.checkmark")
                        .foregroundColor(.orange)
                    Text("This feature is currently in development")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(shape: RoundedRectangle(cornerRadius: 20))
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

// Use shared FeatureRow component with orange color override
struct GroceryFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
struct SmartGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGroceryView()
            .preferredColorScheme(.dark)
    }
}
