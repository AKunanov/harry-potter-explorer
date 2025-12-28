import Combine
import Foundation

@MainActor
final class HousesViewModel: ObservableObject {
    @Published var houses: [House] = []
    @Published var isLoading = false
    @Published var errorText: String? = nil
    
    private var didLoad = false
    private let service: HousesService

    init(service: HousesService = HousesService()) {
        self.service = service
    }

    func load() async {
        guard !didLoad else { return }
        didLoad = true
        
        isLoading = true
        errorText = nil
        defer { isLoading = false }
        do {
            houses = try await service.fetchHouses()
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            errorText = error.localizedDescription
        }
    }
}
