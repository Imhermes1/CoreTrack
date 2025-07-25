import SwiftUI

struct CoachTabContentView: View {
    @EnvironmentObject var userManager: UserManager
    let onTabChange: (MainViewTab) -> Void
    
    var body: some View {
        if userManager.userTier != .free {
            AICoachView(onTabChange: onTabChange)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard { PaywallView().environmentObject(userManager) }
                    Spacer(minLength: 100)
                }
                .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}
