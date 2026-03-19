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

    func append(_ utterance: Utterance) {
        // Deduplicate: when mic picks up system audio, the same speech
        // may appear as both "you" and "them" within a short window.
        // Drop the "you" utterance if a similar "them" utterance exists nearby.
        if utterance.speaker == .you, isDuplicateOfRecentThem(utterance) {
            return
        }
        utterances.append(utterance)
        if utterance.speaker == .them {
            themUtterancesSinceStateUpdate += 1
        }
    }

    /// Check if a "you" utterance is a duplicate of a recent "them" utterance.
    private func isDuplicateOfRecentThem(_ utterance: Utterance) -> Bool {
        let window: TimeInterval = 5 // seconds
        let now = utterance.timestamp
        for recent in utterances.suffix(5).reversed() {
            guard recent.speaker == .them else { continue }
            guard abs(recent.timestamp.timeIntervalSince(now)) < window else { continue }
            if textSimilarity(recent.text, utterance.text) > 0.6 {
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
