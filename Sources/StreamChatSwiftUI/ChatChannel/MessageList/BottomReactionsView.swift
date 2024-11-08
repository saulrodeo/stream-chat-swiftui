//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct BottomReactionsView: View {
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    
    var showsAllInfo: Bool
    var reactionsPerRow: Int
    var onTap: () -> Void
    var onLongPress: () -> Void
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    private let cornerRadius: CGFloat = 12
    private let reactionSize: CGFloat = 20
    
    init(
        message: ChatMessage,
        showsAllInfo: Bool,
        reactionsPerRow: Int = 4,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) {
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.reactionsPerRow = reactionsPerRow
        self.onLongPress = onLongPress
        _viewModel = StateObject(wrappedValue: ReactionsOverlayViewModel(message: message))
    }
    
    var body: some View {
        if reactions.count > 3 {
            let numberOfRows = Int((Double(reactions.count + 1) / Double(reactionsPerRow)).rounded(.up))
            VStack {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    let start = row * reactionsPerRow
                    let end = start + (reactionsPerRow - 1) >= reactions.count ?
                        reactions.count - 1 : start + (reactionsPerRow - 1)
                    let slice = end < start ? [] : Array(reactions[start...end])
                    let isEndRow = slice.isEmpty ? true : end == (reactions.count - 1)
                    HStack {
                        if message.isRightAligned {
                            Spacer()
                        }
                        content(for: slice, isEndRow: isEndRow)
                        if !message.isRightAligned {
                            Spacer()
                        }
                    }
                }
            }
        } else {
            HStack {
                content(for: reactions)
            }
            .offset(y: -2)
        }
    }
    
    private func content(for reactions: [MessageReactionType], isEndRow: Bool = true) -> some View {
        EmptyView()
    }
    
    private var message: ChatMessage {
        viewModel.message
    }
    
    private var reactions: [MessageReactionType] {
        viewModel.reactions
    }
    
    private var cornersForAddReactionButton: UIRectCorner {
        (message.isSentByCurrentUser && showsAllInfo) ?
            [.bottomLeft, .bottomRight, .topLeft] : .allCorners
    }
    
    private func corners(
        for reaction: MessageReactionType,
        in reactions: [MessageReactionType],
        isEndRow: Bool
    ) -> UIRectCorner {
        if message.isSentByCurrentUser || reaction != reactions.first || !showsAllInfo {
            return .allCorners
        }
        if isEndRow {
            return [.bottomLeft, .bottomRight, .topRight]
        } else {
            return .allCorners
        }
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
    
    private func count(for reaction: MessageReactionType) -> Int {
        message.reactionScores[reaction] ?? 0
    }
}
