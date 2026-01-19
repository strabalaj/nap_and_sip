import Foundation
import FirebaseFirestore
import Combine

protocol EventServiceProtocol {
    func createEvent<T: BabyEvent>(_ event: T, for babyId: String) async throws -> String
    func fetchEvents(for babyId: String, limit: Int) async throws -> [any BabyEvent]
    func fetchEvents(for babyId: String, type: EventType, startDate: Date, endDate: Date) async throws -> [any BabyEvent]
    func updateEvent<T: BabyEvent>(_ event: T, for babyId: String) async throws
    func deleteEvent(eventId: String, for babyId: String) async throws
}

final class EventService: EventServiceProtocol {
    static let shared = EventService()

    private let firebase = FirebaseService.shared

    private init() {}

    func createEvent<T: BabyEvent>(_ event: T, for babyId: String) async throws -> String {
        let collection = firebase.eventsCollection(for: babyId)
        return try await firebase.create(event, in: collection)
    }

    func fetchEvents(for babyId: String, limit: Int = 50) async throws -> [any BabyEvent] {
        let collection = firebase.eventsCollection(for: babyId)
        let snapshot = try await collection
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return try snapshot.documents.compactMap { doc -> (any BabyEvent)? in
            guard let typeString = doc.data()["type"] as? String,
                  let eventType = EventType(rawValue: typeString) else {
                return nil
            }

            switch eventType {
            case .feed:
                return try doc.data(as: FeedEvent.self)
            case .sleep:
                return try doc.data(as: SleepEvent.self)
            case .diaper:
                return try doc.data(as: DiaperEvent.self)
            case .milestone:
                return try doc.data(as: MilestoneEvent.self)
            }
        }
    }

    func fetchEvents(for babyId: String, type: EventType, startDate: Date, endDate: Date) async throws -> [any BabyEvent] {
        let collection = firebase.eventsCollection(for: babyId)
        let snapshot = try await collection
            .whereField("type", isEqualTo: type.rawValue)
            .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
            .whereField("timestamp", isLessThanOrEqualTo: endDate)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap { doc -> (any BabyEvent)? in
            switch type {
            case .feed:
                return try doc.data(as: FeedEvent.self)
            case .sleep:
                return try doc.data(as: SleepEvent.self)
            case .diaper:
                return try doc.data(as: DiaperEvent.self)
            case .milestone:
                return try doc.data(as: MilestoneEvent.self)
            }
        }
    }

    func updateEvent<T: BabyEvent>(_ event: T, for babyId: String) async throws {
        guard let eventId = event.id else {
            throw EventServiceError.missingEventId
        }
        let collection = firebase.eventsCollection(for: babyId)
        try await firebase.update(event, documentId: eventId, in: collection)
    }

    func deleteEvent(eventId: String, for babyId: String) async throws {
        let collection = firebase.eventsCollection(for: babyId)
        try await firebase.delete(documentId: eventId, from: collection)
    }

    func observeEvents(for babyId: String, limit: Int = 50) -> AnyPublisher<[any BabyEvent], Error> {
        let subject = PassthroughSubject<[any BabyEvent], Error>()

        let collection = firebase.eventsCollection(for: babyId)
        collection
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }

                let events: [any BabyEvent] = documents.compactMap { doc in
                    guard let typeString = doc.data()["type"] as? String,
                          let eventType = EventType(rawValue: typeString) else {
                        return nil
                    }

                    do {
                        switch eventType {
                        case .feed:
                            return try doc.data(as: FeedEvent.self)
                        case .sleep:
                            return try doc.data(as: SleepEvent.self)
                        case .diaper:
                            return try doc.data(as: DiaperEvent.self)
                        case .milestone:
                            return try doc.data(as: MilestoneEvent.self)
                        }
                    } catch {
                        return nil
                    }
                }

                subject.send(events)
            }

        return subject.eraseToAnyPublisher()
    }
}

enum EventServiceError: LocalizedError {
    case missingEventId

    var errorDescription: String? {
        switch self {
        case .missingEventId:
            return "Event ID is required for this operation"
        }
    }
}
