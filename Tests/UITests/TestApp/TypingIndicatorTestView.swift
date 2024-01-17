import SwiftUI
import SpeziChat

struct TypingIndicatorTestView: View {
    @State private var chat = Chat(arrayLiteral: ChatEntity(role: .user, content: "User Message!"))
    @State private var shouldDisplay: Bool = false
    
    var body: some View {
        MessagesView($chat, loadingDisplayMode: .manual(shouldDisplay: $shouldDisplay))
            .toolbar {
                ToolbarItem {
                    Button {
                        shouldDisplay.toggle()
                    } label: {
                        Image(systemName: "hammer")
                    }
                }
            }
    }
}

#Preview {
    TypingIndicatorTestView()
}
