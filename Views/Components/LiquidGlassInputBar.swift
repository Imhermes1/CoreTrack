import SwiftUI

// MARK: - Quick Action Model
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(title: String, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
}

// MARK: - Liquid Glass Input Bar
struct LiquidGlassInputBar: View {
    @Binding var text: String
    @State private var isExpanded = false
    @State private var showQuickActions = false
    @State private var textFieldHeight: CGFloat = 40
    @State private var isRecording = false
    @State private var recordingScale: CGFloat = 1.0
    
    let placeholder: String
    let quickActions: [QuickAction]
    let onSend: (String) -> Void
    let onMicTap: () -> Void
    let onCameraTap: () -> Void
    
    init(
        text: Binding<String>,
        placeholder: String = "Message",
        quickActions: [QuickAction] = [],
        onSend: @escaping (String) -> Void,
        onMicTap: @escaping () -> Void = {},
        onCameraTap: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.quickActions = quickActions
        self.onSend = onSend
        self.onMicTap = onMicTap
        self.onCameraTap = onCameraTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick Actions Menu (when expanded)
            if showQuickActions && !quickActions.isEmpty {
                QuickActionsMenu(
                    actions: quickActions,
                    isVisible: $showQuickActions
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showQuickActions)
            }
            
            // Main Input Bar
            HStack(spacing: 12) {
                // Quick Actions Button
                Button(action: toggleQuickActions) {
                    ZStack {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(.clear)
                                .glassEffect(
                                    isInteractive: true,
                                    shape: Circle()
                                )
                                .frame(width: 36, height: 36)
                        } else {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                        }
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(showQuickActions ? 45 : 0))
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showQuickActions)
                    }
                }
                .scaleEffect(showQuickActions ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: showQuickActions)
                
                // Text Input Field
                HStack {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .lineLimit(1...5)
                        .onChange(of: text) { _, newValue in
                            updateTextFieldHeight()
                        }
                    
                    // Send Button (appears when text is not empty)
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
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
                .frame(height: max(40, textFieldHeight))
                
                // Camera Button
                Button(action: onCameraTap) {
                    ZStack {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(.clear)
                                .glassEffect(
                                    isInteractive: true,
                                    shape: Circle()
                                )
                                .frame(width: 36, height: 36)
                        } else {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                        }
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                // Microphone Button
                Button(action: handleMicTap) {
                    ZStack {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(.clear)
                                .glassEffect(
                                    isInteractive: true,
                                    shape: Circle()
                                )
                                .frame(width: 36, height: 36)
                        } else {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                        }
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isRecording ? .red : .primary)
                            .scaleEffect(recordingScale)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if #available(iOS 26.0, *) {
                    Rectangle()
                        .fill(.clear)
                        .glassEffect(
                            isInteractive: true,
                            shape: Rectangle()
                        )
                } else {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showQuickActions)
    }
    
    // MARK: - Private Methods
    private func toggleQuickActions() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showQuickActions.toggle()
        }
    }
    
    private func sendMessage() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        onSend(trimmedText)
        text = ""
        updateTextFieldHeight()
        
        // Close quick actions if open
        if showQuickActions {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showQuickActions = false
            }
        }
    }
    
    private func handleMicTap() {
        if isRecording {
            // Stop recording
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isRecording = false
                recordingScale = 1.0
            }
        } else {
            // Start recording
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isRecording = true
                recordingScale = 1.2
            }
            
            // Pulse animation for recording
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                recordingScale = 1.0
            }
        }
        
        onMicTap()
    }
    
    private func updateTextFieldHeight() {
        // Calculate height based on text content
        let lines = text.components(separatedBy: .newlines).count
        let baseHeight: CGFloat = 40
        let lineHeight: CGFloat = 20
        textFieldHeight = min(baseHeight + CGFloat(max(0, lines - 1)) * lineHeight, 120)
    }
}

// MARK: - Quick Actions Menu
struct QuickActionsMenu: View {
    let actions: [QuickAction]
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(actions) { action in
                QuickActionButton(action: action) {
                    action.action()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isVisible = false
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.clear)
                    .glassEffect(
                        isInteractive: true,
                        shape: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(action.color)
                    .frame(width: 24, height: 24)
                
                Text(action.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isPressed ? action.color.opacity(0.1) : Color.clear)
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
struct LiquidGlassInputBar_Previews: PreviewProvider {
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
                
                LiquidGlassInputBar(
                    text: .constant(""),
                    placeholder: "Type a message...",
                    quickActions: [
                        QuickAction(title: "Photo", icon: "photo", color: .blue) {
                            print("Photo tapped")
                        },
                        QuickAction(title: "Document", icon: "doc", color: .green) {
                            print("Document tapped")
                        },
                        QuickAction(title: "Location", icon: "location", color: .orange) {
                            print("Location tapped")
                        }
                    ],
                    onSend: { message in
                        print("Message sent: \(message)")
                    },
                    onMicTap: {
                        print("Mic tapped")
                    },
                    onCameraTap: {
                        print("Camera tapped")
                    }
                )
                .padding(.bottom, 34) // Safe area
            }
        }
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 15 Pro")
    }
}
#endif