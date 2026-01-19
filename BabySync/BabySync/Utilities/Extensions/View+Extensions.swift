import SwiftUI


extension View {
    func cardStyle() -> some View {
        self
            .padding(Constants.Spacing.md)
            .background(Color(.systemBackground))
            .cornerRadius(Constants.CornerRadius.md)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(Constants.CornerRadius.md)
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(Constants.CornerRadius.md)
    }

    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func onTapHideKeyboard() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}
