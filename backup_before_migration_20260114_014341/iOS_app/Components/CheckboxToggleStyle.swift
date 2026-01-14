import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(configuration.isOn ? color : .secondary)
                    .contentTransition(.symbolEffect(.replace))

                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkboxStyle: CheckboxToggleStyle { CheckboxToggleStyle() }

    static func checkboxStyle(color: Color) -> CheckboxToggleStyle {
        CheckboxToggleStyle(color: color)
    }
}

#Preview {
    VStack(spacing: 16) {
        Toggle("Default checkbox", isOn: .constant(false))
            .toggleStyle(.checkboxStyle)

        Toggle("Checked checkbox", isOn: .constant(true))
            .toggleStyle(.checkboxStyle)

        Toggle("Custom color", isOn: .constant(true))
            .toggleStyle(.checkboxStyle(color: .green))
    }
    .padding()
}
