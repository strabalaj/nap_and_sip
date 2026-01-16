import Foundation
import Combine

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var events: [any BabyEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let eventService = EventService.shared
    private var cancellables = Set<AnyCancellable>()
    private var babyId: String?

    func loadEvents(for babyId: String) async {
        self.babyId = babyId
        isLoading = true
        errorMessage = nil

        do {
            events = try await eventService.fetchEvents(for: babyId, limit: 50)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to load events", error: error, category: Logger.events)
        }

        isLoading = false
    }

    func observeEvents(for babyId: String) {
        self.babyId = babyId

        eventService.observeEvents(for: babyId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    Logger.error("Failed to observe events", error: error, category: Logger.events)
                }
            } receiveValue: { [weak self] events in
                self?.events = events
            }
            .store(in: &cancellables)
    }

    func deleteEvent(_ event: any BabyEvent) async {
        guard let babyId = babyId, let eventId = event.id else { return }

        do {
            try await eventService.deleteEvent(eventId: eventId, for: babyId)
            events.removeAll { $0.id == eventId }
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to delete event", error: error, category: Logger.events)
        }
    }

    var groupedEvents: [(String, [any BabyEvent])] {
        let grouped = Dictionary(grouping: events) { event in
            event.timestamp.formatted(Constants.DateFormats.dateOnly)
        }

        return grouped.sorted { $0.key > $1.key }
    }

    func clearError() {
        errorMessage = nil
    }
}
