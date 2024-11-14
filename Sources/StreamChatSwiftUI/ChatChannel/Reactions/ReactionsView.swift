//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsContainer: View {
    @Injected(\.utils) var utils
    let message: ChatMessage
    var useLargeIcons = false
    var onTapGesture: () -> Void
    var onLongPressGesture: () -> Void

    var body: some View {
        VStack {
            ReactionsHStack(message: message) {
                ReactionsView(
                    message: message,
                    useLargeIcons: useLargeIcons,
                    reactions: reactions
                ) { _ in
                    onTapGesture()
                }
                .onLongPressGesture {
                    onLongPressGesture()
                }
            }

            Spacer()
        }
        .offset(
            x: offsetX,
            y: -20
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsContainer")
    }

    private var reactions: [MessageReactionType] {
        message.reactionScores.flatMap { type, count in
            Array(repeating: type, count: Int(count))
        }
        .sorted(by: utils.sortReactions)
    }

    private var reactionsSize: CGFloat {
        let entrySize = 32
        return CGFloat(message.reactionScores.count * entrySize)
    }

    private var offsetX: CGFloat {
        var offset = reactionsSize / 2
        if message.reactionScores.count == 1 {
            offset = 16
        }
        return message.isRightAligned ? -offset : offset
    }
}

struct ReactionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let message: ChatMessage
    var useLargeIcons = false
    var reactions: [MessageReactionType]
    var onReactionTap: (MessageReactionType) -> Void

    var body: some View {
        HStack(spacing: -10) {
            ForEach(Array(reactions.enumerated()), id: \.offset) { index, reaction in
                ReactionBubble(
                    reaction: reaction,
                    message: message,
                    useLargeIcons: useLargeIcons,
                    isUserReaction: isUserReactionAtIndex(index),
                    onTap: onReactionTap
                )
            }
        }
    }

    private func isUserReactionAtIndex(_ index: Int) -> Bool {
        let userReactionIndices = message.currentUserReactions.compactMap { reaction in
            reactions.firstIndex(of: reaction.type)
        }
        return userReactionIndices.contains(index)
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}

struct ReactionBubble: View {
    let reaction: MessageReactionType
    let message: ChatMessage
    let useLargeIcons: Bool
    let isUserReaction: Bool
    let onTap: (MessageReactionType) -> Void

    var body: some View {
        Button(action: { onTap(reaction) }) {
            HStack(spacing: 4) {
                ReactionIcon(reaction: reaction)
            }
            .padding(6)
            .background(isUserReaction ? Color.blue : Color.gray)
            .clipShape(Circle())
        }
    }
}

public struct ReactionIcon: View {
    let emojiReaction: String

    public init(reaction: MessageReactionType) {
        switch reaction.rawValue {
        case "love":    emojiReaction = "❤️"
        case "haha":    emojiReaction = "😂"
        case "like":    emojiReaction = "👍"
        case "sad":     emojiReaction = "😢"
        case "wow":     emojiReaction = "😮"
        default:        emojiReaction = ""
        }
    }

    public var body: some View {
        Text(emojiReaction)
            .font(.system(size: 24))
            .frame(minWidth: 24, minHeight: 24) // Ensure minimum size for the bubble

    }
}

extension MessageReactionType: Identifiable {
    public var id: String {
        rawValue
    }
}
