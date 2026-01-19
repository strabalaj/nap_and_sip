import SwiftUI

struct InsightCard: View {
    let insight: Insight
    var onDismiss: (() -> Void)?
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: insight.type.icon)
                        .font(.title3)
                        .foregroundColor(typeColor)
                        .frame(width: 36, height: 36)
                        .background(typeColor.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                        Text(insight.insightDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }

                    Spacer()

                    if onDismiss != nil {
                        Button(action: { onDismiss?() }) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if insight.confidence > 0 {
                    HStack(spacing: 4) {
                        ConfidenceBadge(confidence: insight.confidence)
                        Spacer()
                        Text(insight.createdAt.timeAgo())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var typeColor: Color {
        switch insight.type {
        case .pattern: return .blue
        case .recommendation: return .green
        case .achievement: return .yellow
        case .warning: return .orange
        }
    }
}

struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.caption2)
            Text("\(Int(confidence * 100))% confident")
                .font(.caption2)
        }
        .foregroundColor(confidenceColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.15))
        .cornerRadius(8)
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .orange
        default: return .gray
        }
    }
}

struct PredictionCard: View {
    let prediction: Prediction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: prediction.type.icon)
                    .foregroundColor(.purple)
                Text(prediction.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                ConfidenceBadge(confidence: prediction.confidence)
            }

            Text(prediction.predictedTime.formatted(date: .omitted, time: .shortened))
                .font(.title)
                .fontWeight(.bold)

            Text(prediction.displayTimeUntil)
                .font(.subheadline)
                .foregroundColor(prediction.timeUntil < 0 ? .red : .secondary)

            if let duration = prediction.displayDuration {
                HStack {
                    Text("Expected duration:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(duration)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

struct InsightListSection: View {
    let insights: [Insight]
    var onDismiss: ((Insight) -> Void)?
    var onTap: ((Insight) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Insights")
                    .font(.headline)
                Spacer()
            }

            if insights.isEmpty {
                Text("No insights yet. Keep logging events to get personalized insights.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(insights) { insight in
                    InsightCard(
                        insight: insight,
                        onDismiss: { onDismiss?(insight) },
                        onTap: { onTap?(insight) }
                    )
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            InsightCard(insight: Insight(
                id: nil,
                babyId: "1",
                type: .pattern,
                title: "Sleep Pattern Detected",
                insightDescription: "Your baby tends to sleep better after feeding. Consider a feed before the next nap.",
                confidence: 0.85,
                data: [:],
                actionable: false,
                actionTitle: nil,
                actionRoute: nil,
                createdAt: Date(),
                expiresAt: nil,
                dismissed: false
            ))

            InsightCard(insight: Insight(
                id: nil,
                babyId: "1",
                type: .recommendation,
                title: "Wake Window Suggestion",
                insightDescription: "Based on age, optimal wake windows are 1.5-2 hours.",
                confidence: 0.92,
                data: [:],
                actionable: true,
                actionTitle: "View Schedule",
                actionRoute: nil,
                createdAt: Date(),
                expiresAt: nil,
                dismissed: false
            ))

            PredictionCard(prediction: Prediction(
                babyId: "1",
                type: .nextNap,
                predictedTime: Date().addingTimeInterval(3600),
                predictedDuration: 5400,
                confidence: 0.78,
                basedOn: "Last 7 days",
                updatedAt: Date()
            ))
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
