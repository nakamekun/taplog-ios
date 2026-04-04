import SwiftUI

struct MoodButtonView: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(mood.emoji)
                    .font(.system(size: 30))

                Text(mood.title)
                    .font(.headline)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(mood.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? mood.color.opacity(0.60) : Color.black.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1)
            .shadow(color: isSelected ? mood.color.opacity(0.22) : .clear, radius: 16, y: 10)
            .animation(.spring(response: 0.28, dampingFraction: 0.76), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct MoodButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MoodButtonView(mood: .great, isSelected: true, action: {})
            MoodButtonView(mood: .bad, isSelected: false, action: {})
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
