import Foundation

@MainActor
final class QuickLogViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let eventService = EventService.shared
    private let authService = AuthService.shared

    func logFeed(
        babyId: String,
        method: FeedEvent.FeedMethod,
        volume: Double? = nil,
        side: FeedEvent.BreastSide? = nil,
        duration: Int? = nil,
        foodType: String? = nil,
        notes: String? = nil
    ) async {
        guard let userId = authService.currentUserId else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        let event = FeedEvent(
            babyId: babyId,
            createdBy: userId,
            method: method,
            volume: volume,
            side: side,
            duration: duration,
            foodType: foodType
        )

        let validationErrors = event.validate()
        if !validationErrors.isEmpty {
            errorMessage = validationErrors.joined(separator: ", ")
            isLoading = false
            return
        }

        do {
            _ = try await eventService.createEvent(event, for: babyId)
            successMessage = "Feed logged"
            Logger.info("Feed event created", category: Logger.events)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to log feed", error: error, category: Logger.events)
        }

        isLoading = false
    }

    func startSleep(babyId: String, isNightSleep: Bool = false) async {
        guard let userId = authService.currentUserId else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        let event = SleepEvent(
            babyId: babyId,
            createdBy: userId,
            startTime: Date(),
            isNightSleep: isNightSleep
        )

        do {
            _ = try await eventService.createEvent(event, for: babyId)
            successMessage = "Sleep started"
            Logger.info("Sleep event started", category: Logger.events)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to start sleep", error: error, category: Logger.events)
        }

        isLoading = false
    }

    func endSleep(event: SleepEvent, babyId: String, quality: SleepEvent.SleepQuality? = nil) async {
        isLoading = true
        errorMessage = nil

        var updatedEvent = event
        updatedEvent.endTime = Date()
        updatedEvent.quality = quality
        updatedEvent.updatedAt = Date()

        do {
            try await eventService.updateEvent(updatedEvent, for: babyId)
            successMessage = "Sleep ended"
            Logger.info("Sleep event ended", category: Logger.events)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to end sleep", error: error, category: Logger.events)
        }

        isLoading = false
    }

    func logDiaper(babyId: String, type: DiaperEvent.DiaperType, notes: String? = nil) async {
        guard let userId = authService.currentUserId else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        let event = DiaperEvent(
            babyId: babyId,
            createdBy: userId,
            notes: notes,
            diaperType: type
        )

        do {
            _ = try await eventService.createEvent(event, for: babyId)
            successMessage = "Diaper logged"
            Logger.info("Diaper event created", category: Logger.events)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to log diaper", error: error, category: Logger.events)
        }

        isLoading = false
    }

    func logMilestone(
        babyId: String,
        title: String,
        category: MilestoneEvent.MilestoneCategory,
        description: String? = nil
    ) async {
        guard let userId = authService.currentUserId else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        let event = MilestoneEvent(
            babyId: babyId,
            createdBy: userId,
            title: title,
            milestoneDescription: description,
            category: category
        )

        do {
            _ = try await eventService.createEvent(event, for: babyId)
            successMessage = "Milestone logged"
            Logger.info("Milestone event created", category: Logger.events)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to log milestone", error: error, category: Logger.events)
        }

        isLoading = false
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
