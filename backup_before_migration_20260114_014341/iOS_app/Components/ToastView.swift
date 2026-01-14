import SwiftUI

struct Toast: Equatable {
    enum ToastType {
        case success
        case error
        case warning
        case info

        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    let id = UUID()
    let type: ToastType
    let title: String
    let message: String?

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.title2)
                .foregroundStyle(toast.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.headline)

                if let message = toast.message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(toast.type.color.opacity(0.3), lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.spring(duration: 0.3)) {
                isVisible = true
            }

            // Auto dismiss after configured duration
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfiguration.UI.toastDismissDuration) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toast {
                    ToastView(toast: toast) {
                        self.toast = nil
                    }
                    .padding()
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.3), value: toast)
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

// MARK: - Toast Manager

@MainActor
@Observable
final class ToastManager {
    static let shared = ToastManager()

    private(set) var currentToast: Toast?

    private init() {}

    func show(_ toast: Toast) {
        currentToast = toast
    }

    func showSuccess(_ title: String, message: String? = nil) {
        show(Toast(type: .success, title: title, message: message))
    }

    func showError(_ title: String, message: String? = nil) {
        show(Toast(type: .error, title: title, message: message))
    }

    func showWarning(_ title: String, message: String? = nil) {
        show(Toast(type: .warning, title: title, message: message))
    }

    func showInfo(_ title: String, message: String? = nil) {
        show(Toast(type: .info, title: title, message: message))
    }

    func dismiss() {
        currentToast = nil
    }
}

#Preview {
    VStack {
        Spacer()
    }
    .frame(width: 400, height: 300)
    .toast(.constant(Toast(type: .success, title: "Goal Completed!", message: "Great job finishing your task")))
}
