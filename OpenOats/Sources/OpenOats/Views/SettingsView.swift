import SwiftUI
import CoreAudio
import Sparkle

struct SettingsView: View {
    private enum TemplateField: Hashable {
        case name
    }

    @Bindable var settings: AppSettings
    var updater: SPUUpdater
    @Environment(AppCoordinator.self) private var coordinator
    @State private var inputDevices: [(id: AudioDeviceID, name: String)] = []
    @State private var isAddingTemplate = false
    @State private var newTemplateName = ""
    @State private var newTemplateIcon = "doc.text"
    @State private var newTemplatePrompt = ""
    @FocusState private var focusedTemplateField: TemplateField?

    private var s: Strings { settings.strings }

    var body: some View {
        Form {
            Section(s.language) {
                Picker(s.language, selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .font(.system(size: 12))
            }

            Section(s.meetingNotes) {
                Text(s.meetingNotesDesc)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                HStack {
                    Text(settings.notesFolderPath)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button(s.choose) {
                        chooseNotesFolder()
                    }
                }
            }

            Section(s.knowledgeBase) {
                Text(s.kbDesc)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                HStack {
                    Text(settings.kbFolderPath.isEmpty ? s.notSet : settings.kbFolderPath)
                        .font(.system(size: 12))
                        .foregroundStyle(settings.kbFolderPath.isEmpty ? .tertiary : .primary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    if !settings.kbFolderPath.isEmpty {
                        Button(s.clear) {
                            settings.kbFolderPath = ""
                        }
                        .font(.system(size: 12))
                    }

                    Button(s.choose) {
                        chooseKBFolder()
                    }
                }
            }

            Section(s.llmProvider) {
                Picker(s.provider, selection: $settings.llmProvider) {
                    ForEach(LLMProvider.allCases) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .font(.system(size: 12))

                if settings.llmProvider == .openRouter {
                    SecureField(s.apiKey, text: $settings.openRouterApiKey)
                        .font(.system(size: 12, design: .monospaced))

                    TextField(s.model, text: $settings.selectedModel, prompt: Text("e.g. google/gemini-3-flash-preview"))
                        .font(.system(size: 12, design: .monospaced))
                } else {
                    TextField("Ollama URL", text: $settings.ollamaBaseURL, prompt: Text("http://localhost:11434"))
                        .font(.system(size: 12, design: .monospaced))

                    TextField(s.model, text: $settings.ollamaLLMModel, prompt: Text("e.g. qwen3:8b"))
                        .font(.system(size: 12, design: .monospaced))
                }
            }

            Section(s.embeddingProvider) {
                Picker(s.provider, selection: $settings.embeddingProvider) {
                    ForEach(EmbeddingProvider.allCases) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .font(.system(size: 12))

                switch settings.embeddingProvider {
                case .voyageAI:
                    SecureField(s.apiKey, text: $settings.voyageApiKey)
                        .font(.system(size: 12, design: .monospaced))
                case .ollama:
                    TextField(s.embeddingModel, text: $settings.ollamaEmbedModel, prompt: Text("e.g. nomic-embed-text"))
                        .font(.system(size: 12, design: .monospaced))

                    if settings.llmProvider != .ollama {
                        TextField("Ollama URL", text: $settings.ollamaBaseURL, prompt: Text("http://localhost:11434"))
                            .font(.system(size: 12, design: .monospaced))
                    }
                case .openAICompatible:
                    TextField(s.endpointURL, text: $settings.openAIEmbedBaseURL, prompt: Text("http://localhost:8080"))
                        .font(.system(size: 12, design: .monospaced))

                    SecureField(s.apiKeyOptional, text: $settings.openAIEmbedApiKey)
                        .font(.system(size: 12, design: .monospaced))

                    TextField(s.embeddingModel, text: $settings.openAIEmbedModel, prompt: Text("e.g. text-embedding-3-small"))
                        .font(.system(size: 12, design: .monospaced))
                }
            }

            Section(s.audioInput) {
                Picker(s.microphone, selection: $settings.inputDeviceID) {
                    Text(s.systemDefault).tag(AudioDeviceID(0))
                    ForEach(inputDevices, id: \.id) { device in
                        Text(device.name).tag(device.id)
                    }
                }
                .font(.system(size: 12))
            }

            Section(s.transcription) {
                Picker(s.model, selection: $settings.transcriptionModel) {
                    ForEach(TranscriptionModel.allCases) { model in
                        Text(model.displayName).tag(model)
                    }
                }
                .font(.system(size: 12))

                if settings.transcriptionModel.supportsExplicitLanguageHint {
                    TextField(
                        "\(s.localeFieldTitle(for: settings.transcriptionModel)) (e.g. en-US)",
                        text: $settings.transcriptionLocale
                    )
                    .font(.system(size: 12, design: .monospaced))
                }

                Text(s.localeHelpText(for: settings.transcriptionModel))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if settings.transcriptionModel == .remoteQwen3ASR {
                    TextField(s.serverURL, text: $settings.remoteASRBaseURL, prompt: Text("http://mac-mini.local:9876"))
                        .font(.system(size: 12, design: .monospaced))
                }
            }

            Section(s.privacy) {
                Toggle(s.hideFromScreenSharing, isOn: $settings.hideFromScreenShare)
                    .font(.system(size: 12))
                Text(s.hideFromScreenSharingDesc)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Section(s.updates) {
                Toggle(s.autoCheckUpdates, isOn: Binding(
                    get: { updater.automaticallyChecksForUpdates },
                    set: { updater.automaticallyChecksForUpdates = $0 }
                ))
                .font(.system(size: 12))
            }

            Section(s.meetingTemplates) {
                ForEach(coordinator.templateStore.templates) { template in
                    HStack {
                        Image(systemName: template.icon)
                            .frame(width: 20)
                            .foregroundStyle(.secondary)
                        Text(template.name)
                            .font(.system(size: 12))
                        Spacer()
                        if template.isBuiltIn {
                            Image(systemName: "lock")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                            Button(s.reset) {
                                coordinator.templateStore.resetBuiltIn(id: template.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundStyle(.blue)
                        } else {
                            Button {
                                coordinator.templateStore.delete(id: template.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if isAddingTemplate {
                    VStack(alignment: .leading, spacing: 10) {
                        // Name
                        VStack(alignment: .leading, spacing: 3) {
                            Text(s.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                            TextField(s.templateNamePlaceholder, text: $newTemplateName)
                                .font(.system(size: 12))
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: .infinity)
                                .focused($focusedTemplateField, equals: .name)
                        }

                        // Icon picker
                        VStack(alignment: .leading, spacing: 3) {
                            Text(s.icon)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                            IconPickerGrid(selected: $newTemplateIcon)
                        }

                        // System prompt
                        VStack(alignment: .leading, spacing: 3) {
                            Text(s.notesPrompt)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text(s.notesPromptDesc)
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                            ZStack(alignment: .topLeading) {
                                if newTemplatePrompt.isEmpty {
                                    Text(s.templatePromptPlaceholder)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.quaternary)
                                        .padding(.top, 6)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $newTemplatePrompt)
                                    .font(.system(size: 11, design: .monospaced))
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .scrollContentBackground(.hidden)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.quaternary)
                            )
                        }

                        HStack {
                            Button(s.cancel) {
                                resetNewTemplateForm()
                            }
                            .buttonStyle(.plain)
                            Button(s.save) {
                                let template = MeetingTemplate(
                                    id: UUID(),
                                    name: trimmedTemplateName,
                                    icon: newTemplateIcon,
                                    systemPrompt: trimmedTemplatePrompt,
                                    isBuiltIn: false
                                )
                                coordinator.templateStore.add(template)
                                resetNewTemplateForm()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canSaveNewTemplate)
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    Button(s.newTemplate) {
                        isAddingTemplate = true
                        Task { @MainActor in
                            focusedTemplateField = .name
                        }
                    }
                    .font(.system(size: 12))
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 700)
        .onAppear {
            inputDevices = MicCapture.availableInputDevices()
        }
    }

    private func chooseKBFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = s.chooseKBDocsMessage

        if panel.runModal() == .OK, let url = panel.url {
            settings.kbFolderPath = url.path
        }
    }

    private func chooseNotesFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = s.chooseNotesMessage

        if panel.runModal() == .OK, let url = panel.url {
            settings.notesFolderPath = url.path
        }
    }

    private var trimmedTemplateName: String {
        newTemplateName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTemplatePrompt: String {
        newTemplatePrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSaveNewTemplate: Bool {
        !trimmedTemplateName.isEmpty && !trimmedTemplatePrompt.isEmpty
    }

    private func resetNewTemplateForm() {
        isAddingTemplate = false
        newTemplateName = ""
        newTemplateIcon = "doc.text"
        newTemplatePrompt = ""
        focusedTemplateField = nil
    }
}

// MARK: - Icon Picker

private struct IconPickerGrid: View {
    @Binding var selected: String

    private static let icons = [
        "doc.text", "person.2", "person.3", "person.badge.plus",
        "calendar", "clock", "arrow.up.circle", "magnifyingglass",
        "lightbulb", "star", "flag", "bolt",
        "bubble.left.and.bubble.right", "phone", "video",
        "briefcase", "chart.bar", "list.bullet",
        "checkmark.circle", "gear", "globe", "book",
        "pencil", "megaphone",
    ]

    private let columns = Array(repeating: GridItem(.fixed(28), spacing: 4), count: 8)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Self.icons, id: \.self) { icon in
                Button {
                    selected = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selected == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(selected == icon ? Color.accentColor : Color.clear, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(selected == icon ? .primary : .secondary)
            }
        }
    }
}
