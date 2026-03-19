import Foundation
import Observation

@Observable
@MainActor
final class TranscriptStore {
    private(set) var utterances: [Utterance] = []
    private(set) var conversationState: ConversationState = .empty
    var volatileYouText: String = ""
    var volatileThemText: String = ""

    /// Count of finalized them-utterances since last state update
    private var themUtterancesSinceStateUpdate: Int = 0

    // MARK: - Auto echo suppression

    /// Tracks recent "you" utterances: true = echo (matched "them"), false = unique
    private var recentYouEchoResults: [Bool] = []
    /// When true, all "you" utterances are suppressed while "them" is active
    private(set) var autoListenMode = false
    /// Timestamp of last "them" utterance for activity detection
    private var lastThemTimestamp: Date?

    func append(_ utterance: Utterance) {
        if utterance.speaker == .you {
            let isEcho = isDuplicateOfRecentThem(utterance)

            // Track echo history (sliding window of 5)
            recentYouEchoResults.append(isEcho)
            if recentYouEchoResults.count > 5 {
                recentYouEchoResults.removeFirst()
            }

            // Enter auto-listen mode when 3+ of last 5 "you" utterances were echo
            let echoCount = recentYouEchoResults.filter { $0 }.count
            if echoCount >= 3 {
                autoListenMode = true
            }

            // In auto-listen mode, suppress "you" while "them" is actively speaking
            if autoListenMode {
                if isEcho || themIsActive {
                    return
                }
                // "Them" went silent and "you" is unique → exit auto-listen
                autoListenMode = false
                recentYouEchoResults.removeAll()
            } else if isEcho {
                return
            }
        }

        utterances.append(utterance)
        if utterance.speaker == .them {
            themUtterancesSinceStateUpdate += 1
            lastThemTimestamp = utterance.timestamp
        }
    }

    /// Whether "them" speaker has been active within the last 8 seconds.
    private var themIsActive: Bool {
        guard let last = lastThemTimestamp else { return false }
        return Date().timeIntervalSince(last) < 8
    }

    /// Check if a "you" utterance is a duplicate of a recent "them" utterance.
    private func isDuplicateOfRecentThem(_ utterance: Utterance) -> Bool {
        let window: TimeInterval = 6
        let now = utterance.timestamp
        for recent in utterances.suffix(6).reversed() {
            guard recent.speaker == .them else { continue }
            guard abs(recent.timestamp.timeIntervalSince(now)) < window else { continue }
            if textSimilarity(recent.text, utterance.text) > 0.5 {
                return true
            }
        }
        return false
    }

    /// Simple word-overlap similarity (Jaccard index).
    private func textSimilarity(_ a: String, _ b: String) -> Double {
        let wordsA = Set(a.lowercased().split(separator: " "))
        let wordsB = Set(b.lowercased().split(separator: " "))
        guard !wordsA.isEmpty || !wordsB.isEmpty else { return 1.0 }
        let intersection = wordsA.intersection(wordsB).count
        let union = wordsA.union(wordsB).count
        return union > 0 ? Double(intersection) / Double(union) : 0
    }

    func clear() {
        utterances.removeAll()
        volatileYouText = ""
        volatileThemText = ""
        conversationState = .empty
        themUtterancesSinceStateUpdate = 0
        recentYouEchoResults.removeAll()
        autoListenMode = false
        lastThemTimestamp = nil
    }

    func updateConversationState(_ state: ConversationState) {
        conversationState = state
        themUtterancesSinceStateUpdate = 0
    }

    /// Whether conversation state needs a refresh (every 2-3 finalized them-utterances)
    var needsStateUpdate: Bool {
        themUtterancesSinceStateUpdate >= 2
    }

    var lastThemUtterance: Utterance? {
        utterances.last(where: { $0.speaker == .them })
    }

    /// Last N utterances for prompt context
    var recentUtterances: [Utterance] {
        Array(utterances.suffix(10))
    }

    /// Recent 6 utterances for gate/generation prompts
    var recentExchange: [Utterance] {
        Array(utterances.suffix(6))
    }

    /// Recent them-only utterances for trigger analysis
    var recentThemUtterances: [Utterance] {
        utterances.suffix(10).filter { $0.speaker == .them }
    }
}
