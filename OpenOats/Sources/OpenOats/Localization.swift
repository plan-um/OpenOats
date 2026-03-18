import Foundation

// MARK: - App Language

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case korean

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: "English"
        case .korean: "한국어"
        }
    }
}

// MARK: - Localized Strings

struct Strings {
    let lang: AppLanguage
    private var ko: Bool { lang == .korean }

    // MARK: Common
    var cancel: String { ko ? "취소" : "Cancel" }
    var you: String { ko ? "나" : "You" }
    var them: String { ko ? "상대방" : "Them" }
    var template: String { ko ? "템플릿" : "Template" }
    var model: String { ko ? "모델" : "Model" }
    var provider: String { ko ? "제공자" : "Provider" }
    var apiKey: String { ko ? "API 키" : "API Key" }
    var generateNotes: String { ko ? "노트 생성" : "Generate Notes" }
    var none: String { ko ? "없음" : "None" }

    // MARK: ContentView
    func sessionEnded(_ count: Int) -> String {
        ko ? "세션 종료 · \(count)개 발화" : "Session ended · \(count) utterances"
    }
    var suggestions: String { ko ? "제안" : "SUGGESTIONS" }
    var transcript: String { ko ? "대화 기록" : "Transcript" }
    var copyTranscript: String { ko ? "대화 기록 복사" : "Copy transcript" }
    var setKBFolder: String { ko ? "지식 베이스 폴더 설정..." : "Set KB Folder..." }
    var change: String { ko ? "변경..." : "Change..." }
    var openInFinder: String { ko ? "Finder에서 열기" : "Open in Finder" }
    func filesCount(_ count: Int) -> String {
        ko ? "\(count)개 파일" : "\(count) files"
    }
    var chooseKBFolderMessage: String {
        ko ? "지식 베이스 폴더를 선택하세요" : "Choose your knowledge base folder"
    }

    // MARK: SettingsView
    var language: String { ko ? "언어" : "Language" }
    var meetingNotes: String { ko ? "회의 노트" : "Meeting Notes" }
    var meetingNotesDesc: String {
        ko ? "회의 대화 기록이 텍스트 파일로 저장되는 위치입니다."
            : "Where meeting transcripts are saved as plain text files."
    }
    var choose: String { ko ? "선택..." : "Choose..." }
    var knowledgeBase: String { ko ? "지식 베이스" : "Knowledge Base" }
    var kbDesc: String {
        ko ? "선택 사항. 미팅 중 관련 정보를 제공할 문서 폴더(.md, .txt)를 지정하세요. OpenOats가 이 폴더를 검색하여 관련 컨텍스트와 대화 포인트를 제안합니다."
            : "Optional. Point this to a folder of notes, docs, or reference material (.md, .txt). During meetings, OpenOats searches this folder to surface relevant context and talking points."
    }
    var notSet: String { ko ? "미설정" : "Not set" }
    var clear: String { ko ? "초기화" : "Clear" }
    var llmProvider: String { ko ? "LLM 제공자" : "LLM Provider" }
    var embeddingProvider: String { ko ? "임베딩 제공자" : "Embedding Provider" }
    var embeddingModel: String { ko ? "임베딩 모델" : "Embedding Model" }
    var endpointURL: String { ko ? "엔드포인트 URL" : "Endpoint URL" }
    var apiKeyOptional: String { ko ? "API 키 (선택)" : "API Key (optional)" }
    var audioInput: String { ko ? "오디오 입력" : "Audio Input" }
    var microphone: String { ko ? "마이크" : "Microphone" }
    var systemDefault: String { ko ? "시스템 기본값" : "System Default" }
    var transcription: String { ko ? "음성 인식" : "Transcription" }
    var privacy: String { ko ? "개인정보" : "Privacy" }
    var hideFromScreenSharing: String { ko ? "화면 공유에서 숨기기" : "Hide from screen sharing" }
    var hideFromScreenSharingDesc: String {
        ko ? "활성화하면 화면 공유 및 녹화 시 앱이 보이지 않습니다."
            : "When enabled, the app is invisible during screen sharing and recording."
    }
    var updates: String { ko ? "업데이트" : "Updates" }
    var autoCheckUpdates: String { ko ? "자동 업데이트 확인" : "Automatically check for updates" }
    var meetingTemplates: String { ko ? "미팅 템플릿" : "Meeting Templates" }
    var reset: String { ko ? "초기화" : "Reset" }
    var name: String { ko ? "이름" : "Name" }
    var icon: String { ko ? "아이콘" : "Icon" }
    var notesPrompt: String { ko ? "노트 프롬프트" : "Notes Prompt" }
    var notesPromptDesc: String {
        ko ? "AI가 이 미팅 유형의 노트를 어떻게 작성할지에 대한 지시사항입니다."
            : "Instructions for how the AI should format notes for this meeting type."
    }
    var save: String { ko ? "저장" : "Save" }
    var newTemplate: String { ko ? "새 템플릿" : "New Template" }
    var chooseKBDocsMessage: String {
        ko ? "지식 베이스 문서(.md, .txt)가 있는 폴더를 선택하세요"
            : "Choose a folder containing your knowledge base documents (.md, .txt)"
    }
    var chooseNotesMessage: String {
        ko ? "회의 대화 기록을 저장할 위치를 선택하세요"
            : "Choose where to save meeting transcripts"
    }
    var templateNamePlaceholder: String { ko ? "예: 스프린트 플래닝" : "e.g. Sprint Planning" }
    var templatePromptPlaceholder: String {
        ko ? "예: 회의 노트 어시스턴트입니다. 전사 내용을 기반으로 구조화된 노트를 작성하세요..."
            : "e.g. You are a meeting notes assistant. Given a transcript, produce structured notes with sections for..."
    }

    // Transcription model strings
    func downloadPrompt(for model: TranscriptionModel) -> String {
        switch model {
        case .parakeetV2, .parakeetV3:
            ko ? "음성 인식을 위해 모델을 한 번만 다운로드하면 됩니다." : "Transcription requires a one-time model download."
        case .qwen3ASR06B:
            ko ? "Qwen3 ASR 모델을 한 번만 다운로드하면 됩니다." : "Qwen3 ASR requires a one-time model download."
        case .remoteQwen3ASR:
            ko ? "Qwen3 ASR 1.7B가 원격 서버에서 실행됩니다. 설정에서 서버 URL을 구성하세요." : "Qwen3 ASR 1.7B runs on a remote server. Configure the server URL in settings."
        }
    }

    func localeFieldTitle(for model: TranscriptionModel) -> String {
        switch model {
        case .qwen3ASR06B, .remoteQwen3ASR:
            ko ? "언어 힌트" : "Language Hint"
        case .parakeetV2, .parakeetV3:
            ko ? "로케일" : "Locale"
        }
    }

    func localeHelpText(for model: TranscriptionModel) -> String {
        switch model {
        case .parakeetV2:
            ko ? "Parakeet TDT v2는 영어 전용입니다. 로케일 설정은 이 모델에 영향을 주지 않습니다."
                : "Parakeet TDT v2 is English-only. Locale changes do not affect this model."
        case .parakeetV3:
            ko ? "Parakeet TDT v3은 지원 언어를 자동 감지합니다. 로케일 설정은 이 모델에 영향을 주지 않습니다."
                : "Parakeet TDT v3 auto-detects among its supported languages. Locale changes do not affect this model."
        case .qwen3ASR06B:
            ko ? "선택 사항. Qwen3 ASR의 언어 힌트로 사용됩니다. en-US, ko-KR, ja-JP 등의 로케일을 입력하세요. 새 세션 시작 시 적용됩니다."
                : "Optional. Used as a language hint for Qwen3 ASR. Enter a locale such as en-US, fr-FR, or ja-JP. Applies when a new session starts."
        case .remoteQwen3ASR:
            ko ? "원격 Qwen3 ASR 1.7B의 언어 힌트입니다. 한국어는 ko-KR, 영어는 en-US, 일본어는 ja-JP 등."
                : "Language hint for remote Qwen3 ASR 1.7B. Use ko-KR for Korean, en-US for English, ja-JP for Japanese, etc."
        }
    }

    // MARK: SettingsView - Remote ASR
    var remoteASRServer: String { ko ? "원격 ASR 서버" : "Remote ASR Server" }
    var serverURL: String { ko ? "서버 URL" : "Server URL" }

    // MARK: SuggestionsView
    var evaluating: String { ko ? "분석 중..." : "Evaluating..." }
    var noSuggestionsYet: String { ko ? "아직 제안이 없습니다" : "No suggestions yet" }
    var suggestionsHelpText: String {
        ko ? "대화 중 지식 베이스가 도움이 될 수 있는 순간에 제안이 표시됩니다."
            : "Suggestions appear when the conversation reaches a moment where your knowledge base can help."
    }

    // MARK: ControlBar
    var downloadNow: String { ko ? "지금 다운로드" : "Download Now" }
    var live: String { ko ? "실시간" : "Live" }
    var start: String { ko ? "시작" : "Start" }

    // MARK: OverlayContent
    var waitingForConversation: String { ko ? "대화를 기다리는 중..." : "Waiting for conversation..." }

    // MARK: OnboardingView
    var onboardingSteps: [(icon: String, title: String, body: String)] {
        if ko {
            return [
                ("waveform.circle", "OpenOats에 오신 것을 환영합니다",
                 "실시간 미팅 어시스턴트로, 대화를 듣고 스마트한 대화 포인트를 생성합니다. 모두 Mac에서 로컬로 실행됩니다."),
                ("text.quote", "실시간 대화 기록",
                 "대화가 실시간으로 기록됩니다. '나'는 마이크를, '상대방'은 시스템 오디오를 캡처합니다. 대화 기록 패널을 펼쳐 함께 확인하세요."),
                ("lightbulb", "AI 제안",
                 "대화가 진행되면 OpenOats가 지식 베이스에서 관련 정보를 찾아 대화 포인트를 제안합니다. 최적의 제안이 자동으로 표시됩니다."),
                ("rectangle.on.rectangle", "플로팅 오버레이",
                 "오버레이 버튼으로 컴팩트한 플로팅 패널을 띄울 수 있습니다. 미팅 앱 위에 표시되어 창을 전환하지 않고도 제안을 확인할 수 있습니다."),
            ]
        }
        return [
            ("waveform.circle", "Welcome to OpenOats",
             "A real-time meeting copilot that listens to your conversations and generates smart talking points — all running locally on your Mac."),
            ("text.quote", "Live Transcript",
             "Your conversation is transcribed in real time. \"You\" captures your mic, \"Them\" captures system audio from the other side. Expand the transcript panel to follow along."),
            ("lightbulb", "AI Suggestions",
             "As the conversation progresses, OpenOats pulls relevant context from your knowledge base and suggests talking points. The best suggestions surface automatically."),
            ("rectangle.on.rectangle", "Floating Overlay",
             "Use the overlay button to pop out a compact floating panel — it stays on top of your meeting app so you can glance at suggestions without switching windows."),
        ]
    }
    var skip: String { ko ? "건너뛰기" : "Skip" }
    var next: String { ko ? "다음" : "Next" }
    var getStarted: String { ko ? "시작하기" : "Get Started" }

    // MARK: RecordingConsentView
    var recordingConsentNotice: String { ko ? "녹음 동의 안내" : "Recording Consent Notice" }
    var recordingConsentBody: String {
        if ko {
            return """
            OpenOats는 미팅 중 마이크와 시스템 오디오를 녹음하고 \
            전사합니다. 많은 지역에서 녹음 전 모든 참여자의 동의를 \
            요구합니다.

            이 앱을 사용함으로써 다음을 인정합니다:
            """
        }
        return """
        OpenOats records and transcribes audio from your microphone \
        and system audio during meetings. Many jurisdictions require \
        all-party consent before recording a conversation.

        By using this app, you acknowledge that:
        """
    }
    var consentBullet1: String {
        ko ? "녹음 전 모든 참여자로부터 필요한 동의를 얻는 것은 전적으로 사용자의 책임입니다."
            : "You are solely responsible for obtaining any required consent from all participants before recording."
    }
    var consentBullet2: String {
        ko ? "녹음 및 도청에 관한 모든 관련 법률을 준수할 것입니다."
            : "You will comply with all applicable local, state, and federal laws governing recording and wiretapping."
    }
    var consentBullet3: String {
        ko ? "OpenOats 개발자는 무단 또는 불법 녹음에 대해 어떠한 책임도 지지 않습니다."
            : "The developers of OpenOats accept no liability for unauthorized or unlawful recording."
    }
    var consentAcknowledge: String {
        ko ? "위 의무를 이해하고 동의합니다" : "I understand and accept these obligations"
    }
    var iAgree: String { ko ? "동의합니다" : "I Agree" }

    // MARK: NotesView
    var sessions: String { ko ? "세션" : "Sessions" }
    var untitled: String { ko ? "제목 없음" : "Untitled" }
    func utterancesCount(_ count: Int) -> String {
        ko ? "\(count)개 발화" : "\(count) utterances"
    }
    var generatingNotes: String { ko ? "노트 생성 중..." : "Generating notes..." }
    var generated: String { ko ? "생성됨" : "Generated" }
    var ago: String { ko ? "전" : "ago" }
    var copy: String { ko ? "복사" : "Copy" }
    var regenerate: String { ko ? "다시 생성" : "Regenerate" }
    var selectSession: String { ko ? "세션을 선택하세요" : "Select a Session" }
    var selectSessionDesc: String {
        ko ? "사이드바에서 세션을 선택하여 노트를 확인하거나 생성하세요."
            : "Choose a session from the sidebar to view or generate notes."
    }
    func moreUtterances(_ count: Int) -> String {
        ko ? "... 외 \(count)개 발화" : "... and \(count) more utterances"
    }
    var notes: String { ko ? "노트" : "Notes" }

    // MARK: CheckForUpdatesView
    var checkForUpdates: String { ko ? "업데이트 확인..." : "Check for Updates..." }
}

// MARK: - Convenience

extension AppSettings {
    var strings: Strings { Strings(lang: appLanguage) }
}
