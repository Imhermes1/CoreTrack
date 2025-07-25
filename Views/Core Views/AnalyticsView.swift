import SwiftUI
import Charts

struct AnalyticsView: View {
        let onTabChange: (MainViewTab) -> Void

    init(onTabChange: @escaping (MainViewTab) -> Void = { _ in }) {
        self.onTabChange = onTabChange
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.indigo.opacity(0.08), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 30)
            .overlay(Color.white.opacity(0.02).blur(radius: 15))
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                HStack(spacing: 12) {
                    Button(action: {
                        // No state or animation needed here now
                    }) {
                        Circle()
                            .fill(LinearGradient(colors: [Color.cyan, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "chart.bar.fill").font(.title2.bold()).foregroundColor(.white))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Analytics").font(.headline).foregroundColor(.white)
                        Text("Data Insights").font(.caption).foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 20)
                
                // Feature Icon
                ZStack {
                    Circle()
                        .frame(width: 120, height: 120)
                        .glassEffect(shape: Circle())
                    
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 50))
                        .foregroundColor(.indigo)
                }
                
                // Title and Description
                VStack(spacing: 16) {
                    Text("Professional Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                }
                
                // Professional Description
                VStack(spacing: 20) {
                    Text("World-class detailed nutrition analytics for professionals")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        AnalyticsFeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Comprehensive Nutrient Analysis",
                            description: "Detailed breakdown of all macronutrients, micronutrients, vitamins, minerals, and antioxidants"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "calendar.badge.clock",
                            title: "Advanced Trend Analysis",
                            description: "Long-term nutritional patterns, seasonal variations, and detailed progress tracking"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "target",
                            title: "Goal-Based Analytics",
                            description: "Compare intake against personalised targets and generate detailed recommendations"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "doc.text.chart",
                            title: "Professional Reports",
                            description: "Export comprehensive PDF reports for nutrition professionals and personal records"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "chart.pie.fill",
                            title: "Advanced Nutrient Ratios",
                            description: "Detailed analysis of omega-3/6 ratios, protein quality scores, and micronutrient balance"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "clock.arrow.circlepath",
                            title: "Meal Timing & Frequency",
                            description: "Comprehensive analysis of eating windows, meal frequency, and circadian rhythm patterns"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "chart.bar.doc.horizontal",
                            title: "Detailed Food Analysis",
                            description: "Complete breakdown of food sources, quality metrics, and nutritional density scores"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "chart.xyaxis.line",
                            title: "Correlation Analysis",
                            description: "Identify relationships between nutrition, energy levels, and health outcomes"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "chart.dots.scatter",
                            title: "Statistical Insights",
                            description: "Advanced statistical analysis of eating patterns, variance, and consistency metrics"
                        )
                        
                        AnalyticsFeatureRow(
                            icon: "doc.richtext",
                            title: "Comprehensive Reports",
                            description: "Generate detailed reports for nutrition professionals and personal records"
                        )
                    }
                }
                
                Spacer()
                
                // Professional Features Highlight
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.yellow)
                        Text("Professional Features")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("Designed for Nutrition Professionals and Personal Trainers")
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
                        .foregroundColor(.indigo)
                    Text("Advanced analytics launching soon!")
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
    
    
    struct AnalyticsFeatureRow: View {
        let icon: String
        let title: String
        let description: String
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.indigo)
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
    struct AnalyticsView_Previews: PreviewProvider {
        static var previews: some View {
            AnalyticsView()
                .preferredColorScheme(.dark)
        }
    }
    
}
