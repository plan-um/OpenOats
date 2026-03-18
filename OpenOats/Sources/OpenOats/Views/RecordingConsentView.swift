import SwiftUI

/// Modal sheet requiring users to acknowledge their obligation to comply with
/// applicable recording consent laws before using the transcription feature.
struct RecordingConsentView: View {
    @Binding var isPresented: Bool
    @Bindable var settings: AppSettings
    @State private var acknowledged = false

    private var s: Strings { settings.strings }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "exclamationmark.shield")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.orange)
                .frame(height: 52)

            Spacer().frame(height: 20)

            Text(s.recordingConsentNotice)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)

            Spacer().frame(height: 10)

            Text(s.recordingConsentBody)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 12)

            VStack(alignment: .leading, spacing: 8) {
                consentBullet(s.consentBullet1)
                consentBullet(s.consentBullet2)
                consentBullet(s.consentBullet3)
            }
            .padding(.horizontal, 8)

            Spacer().frame(height: 16)

            Toggle(isOn: $acknowledged) {
                Text(s.consentAcknowledge)
                    .font(.system(size: 12, weight: .medium))
            }
            .toggleStyle(.checkbox)

            Spacer()

            HStack {
                Button(s.cancel) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

                Spacer()

                Button {
                    settings.hasAcknowledgedRecordingConsent = true
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                } label: {
                    Text(s.iAgree)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            acknowledged ? Color.accentTeal : Color.gray,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!acknowledged)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }

    private func consentBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\u{2022}")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
