import Foundation
import Combine

@MainActor
final class BabyViewModel: ObservableObject {
    @Published var babies: [Baby] = []
    @Published var selectedBaby: Baby?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let babyService = BabyService.shared
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBabiesListener()
    }

    private func setupBabiesListener() {
        guard let userId = authService.currentUserId else { return }

        babyService.observeBabies(for: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    Logger.error("Failed to observe babies", error: error)
                }
            } receiveValue: { [weak self] babies in
                self?.babies = babies
                if self?.selectedBaby == nil, let firstBaby = babies.first {
                    self?.selectedBaby = firstBaby
                }
            }
            .store(in: &cancellables)
    }

    func createBaby(name: String, dateOfBirth: Date, gender: Baby.Gender?) async {
        guard let userId = authService.currentUserId else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        let baby = Baby(
            name: name,
            dateOfBirth: dateOfBirth,
            gender: gender,
            owners: [userId],
            createdBy: userId
        )

        do {
            let babyId = try await babyService.createBaby(baby)
            Logger.info("Baby created with ID: \(babyId)")
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to create baby", error: error)
        }

        isLoading = false
    }

    func updateBaby(_ baby: Baby) async {
        isLoading = true
        errorMessage = nil

        do {
            var updatedBaby = baby
            updatedBaby.updatedAt = Date()
            try await babyService.updateBaby(updatedBaby)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to update baby", error: error)
        }

        isLoading = false
    }

    func selectBaby(_ baby: Baby) {
        selectedBaby = baby
    }

    func clearError() {
        errorMessage = nil
    }
}
