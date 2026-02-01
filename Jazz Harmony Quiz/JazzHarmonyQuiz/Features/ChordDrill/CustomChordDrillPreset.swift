import Foundation

// MARK: - Custom Chord Drill Preset

/// A user-created preset for chord drills
/// Implements requirements from DESIGN.md for custom preset functionality
struct CustomChordDrillPreset: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var config: ChordDrillConfig
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, config: ChordDrillConfig, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.config = config
        self.createdAt = createdAt
    }
    
    /// Validates the preset configuration
    var isValid: Bool {
        // Name must not be empty
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        
        // Must have at least one question type
        guard !config.questionTypes.isEmpty else { return false }
        
        // Question count must be reasonable
        guard config.questionCount >= 1 && config.questionCount <= 100 else { return false }
        
        return true
    }
}

// MARK: - Save Preset Result

/// Result of attempting to save a custom preset
struct SavePresetResult {
    let success: Bool
    let error: SavePresetError?
    
    static func succeeded() -> SavePresetResult {
        SavePresetResult(success: true, error: nil)
    }
    
    static func failed(_ error: SavePresetError) -> SavePresetResult {
        SavePresetResult(success: false, error: error)
    }
}

/// Errors that can occur when saving a preset
enum SavePresetError: Equatable {
    case emptyName
    case duplicateName
    case atMaxLimit
    case invalidConfig
}

// MARK: - Custom Preset Store

/// Manages persistence of custom chord drill presets
/// Uses UserDefaults for storage with a maximum limit
class CustomPresetStore: ObservableObject {
    
    // MARK: - Shared Instance
    
    /// Shared instance for app-wide use - avoids repeated UserDefaults loading
    static let shared = CustomPresetStore()
    
    // MARK: - Constants
    
    static let maxPresets = 20
    private static let storageKey = "customChordDrillPresets"
    
    // MARK: - Published Properties
    
    @Published private(set) var presets: [CustomChordDrillPreset] = []
    
    // MARK: - Computed Properties
    
    /// Returns all presets sorted by creation date (newest first)
    var allPresets: [CustomChordDrillPreset] {
        presets.sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Dependencies
    
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadPresets()
    }
    
    // MARK: - Public Methods
    
    /// Save a new preset
    /// - Returns: SavePresetResult indicating success or failure with error
    @discardableResult
    func savePreset(_ preset: CustomChordDrillPreset) -> SavePresetResult {
        // Validate name is not empty
        let trimmedName = preset.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failed(.emptyName)
        }
        
        // Check for duplicate name
        if presets.contains(where: { $0.name == preset.name }) {
            return .failed(.duplicateName)
        }
        
        // Validate config
        guard preset.isValid else {
            return .failed(.invalidConfig)
        }
        
        // If at max limit, remove the oldest preset
        if presets.count >= Self.maxPresets {
            // Remove the oldest (by creation date)
            if let oldestIndex = presets.indices.min(by: { presets[$0].createdAt < presets[$1].createdAt }) {
                presets.remove(at: oldestIndex)
            }
        }
        
        presets.append(preset)
        persistPresets()
        return .succeeded()
    }
    
    /// Delete a preset
    func deletePreset(_ preset: CustomChordDrillPreset) {
        presets.removeAll { $0.id == preset.id }
        persistPresets()
    }
    
    /// Delete a preset by ID
    func deletePreset(withID id: UUID) {
        presets.removeAll { $0.id == id }
        persistPresets()
    }
    
    /// Delete all presets
    func deleteAllPresets() {
        presets = []
        userDefaults.removeObject(forKey: Self.storageKey)
    }
    
    /// Update an existing preset
    func updatePreset(_ preset: CustomChordDrillPreset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index] = preset
        persistPresets()
    }
    
    /// Get a preset by ID
    func getPreset(withID id: UUID) -> CustomChordDrillPreset? {
        presets.first { $0.id == id }
    }
    
    /// Check if can add more presets
    var canAddMore: Bool {
        presets.count < Self.maxPresets
    }
    
    // MARK: - Private Methods
    
    private func loadPresets() {
        guard let data = userDefaults.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([CustomChordDrillPreset].self, from: data) else {
            return
        }
        presets = decoded
    }
    
    private func persistPresets() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        userDefaults.set(data, forKey: Self.storageKey)
    }
}
