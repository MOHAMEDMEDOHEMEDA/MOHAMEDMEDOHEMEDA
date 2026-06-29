//
//  MessagesViewModel.swift
//  Binbon
//
//  Drives the Messages list, the relationship filter tabs, and the two header
//  popovers (Mood = theme switch, Do-Not-Disturb = schedule). Mock-backed for
//  now; selecting a filter only updates the highlight until the API can scope
//  conversations by relationship.
//

import Combine
import Foundation

/// Which header popover is currently open (anchored under its pill).
enum MessagesPopup: Equatable {
    case mood
    case doNotDisturb
}

/// Actions in the long-press context menu shown over a conversation row.
enum MessageRowAction: String, CaseIterable, Identifiable {
    case moveToFavorites
    case report
    case doNotDisturb
    case hide
    case moveToGroup
    case addToGroup

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .moveToFavorites: return "messages_row_move_favorites"
        case .report:          return "messages_row_report"
        case .doNotDisturb:    return "messages_row_dnd"
        case .hide:            return "messages_row_hide"
        case .moveToGroup:     return "messages_row_move_group"
        case .addToGroup:      return "messages_row_add_group"
        }
    }
}

/// Options in the "add to group" dialog (إضافة الى جروب).
enum AddToGroupOption: String, CaseIterable, Identifiable {
    case family, agency

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .family: return "messages_add_group_family"
        case .agency: return "messages_add_group_agency"
        }
    }
}

/// Do-Not-Disturb schedule shown in the عدم الإزعاج popover. `off` is the
/// resting state (no schedule, pill inactive).
enum DoNotDisturbMode: String, CaseIterable, Identifiable {
    case off, night, day, always

    var id: String { rawValue }

    /// Options listed in the popover (the resting `off` state isn't shown).
    static var selectable: [DoNotDisturbMode] { [.night, .day, .always] }

    var titleKey: String {
        switch self {
        case .off:    return "messages_do_not_disturb"
        case .night:  return "messages_dnd_night"
        case .day:    return "messages_dnd_day"
        case .always: return "messages_dnd_always"
        }
    }
}

@MainActor
final class MessagesViewModel: ObservableObject {

    @Published private(set) var conversations: [MessageConversation] = []
    @Published var selectedTab: MessageFilterTab = .friends
    @Published var searchText: String = ""
    @Published var activePopup: MessagesPopup?
    @Published var doNotDisturbMode: DoNotDisturbMode = .off
    /// The row whose long-press context menu is open (nil when closed).
    @Published var contextMenuConversation: MessageConversation?
    /// Conversations the user has marked as favourites (المفضلة tab).
    @Published private(set) var favorites: [MessageConversation] = []
    /// Drives the add-to-favourites picker sheet.
    @Published var isAddingToFavorites = false
    /// Row that opened the picker — pre-selected when the sheet appears.
    private(set) var favoriteSeed: MessageConversation?
    /// Drives the Friends-tab report sheet; set to a FriendItem built from the
    /// long-pressed conversation so FriendReportReasonsView can present itself.
    @Published var reportFriend: FriendItem?
    /// Conversations muted via "عدم الإزعاج" (shown with a tappable mute glyph).
    @Published private(set) var mutedIDs: Set<UUID> = []
    /// Conversations hidden via "إخفاء الحساب" (filtered out of every list).
    @Published private(set) var hiddenIDs: Set<UUID> = []
    /// Drives the "نقل الى مجموعة أختارها" flow (people picker → group picker).
    @Published var isMovingToGroup = false
    /// Row that opened the move-to-group picker — pre-selected on appear.
    private(set) var groupSeed: MessageConversation?
    /// Drives the "إضافة الى جروب" dialog (family / agency).
    @Published var isAddingToGroup = false
    /// Row that opened the add-to-group dialog.
    private(set) var addGroupSeed: MessageConversation?

    private let loadConversationsUseCase: LoadConversationsUseCase

    init(loadConversationsUseCase: LoadConversationsUseCase) {
        self.loadConversationsUseCase = loadConversationsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(loadConversationsUseCase: container.makeLoadConversationsUseCase())
    }

    var doNotDisturbActive: Bool { doNotDisturbMode != .off }

    /// Conversations for the selected tab, after the search filter. The وكيل
    /// (agent) and مجموعات (groups) tabs swap in their own mock sets; the other
    /// relationship tabs are visual-only for now and share the default list.
    var visibleConversations: [MessageConversation] {
        let base: [MessageConversation]
        switch selectedTab {
        case .management: base = MessageConversation.managementSamples
        case .groups:     base = MessageConversation.groupSamples
        case .favorites:  base = favorites
        default:          base = conversations
        }
        let visible = base.filter { !hiddenIDs.contains($0.id) }
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return visible }
        return visible.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func isMuted(_ conversation: MessageConversation) -> Bool {
        mutedIDs.contains(conversation.id)
    }

    func load() {
        Task {
            do {
                conversations = try await loadConversationsUseCase.execute()
            } catch {
                conversations = []
            }
        }
    }

    func select(_ tab: MessageFilterTab) {
        selectedTab = tab
    }

    // MARK: - Header popovers

    func togglePopup(_ popup: MessagesPopup) {
        activePopup = (activePopup == popup) ? nil : popup
    }

    func closePopup() {
        activePopup = nil
    }

    /// Mood popover → switch the app theme.
    func selectTheme(_ mode: AppThemeMode) {
        ThemeManager.shared.select(mode)
        closePopup()
    }

    func selectDoNotDisturb(_ mode: DoNotDisturbMode) {
        doNotDisturbMode = (doNotDisturbMode == mode) ? .off : mode
        closePopup()
    }

    // MARK: - Row context menu (long press)

    func openContextMenu(_ conversation: MessageConversation) {
        contextMenuConversation = conversation
    }

    func closeContextMenu() {
        contextMenuConversation = nil
    }

    /// UI-only for now — most actions just dismiss the menu. "Move to favourites"
    /// opens the multi-select picker seeded with the long-pressed row.
    func performRowAction(_ action: MessageRowAction) {
        let seed = contextMenuConversation
        closeContextMenu()
        switch action {
        case .moveToFavorites:
            favoriteSeed = seed
            isAddingToFavorites = true
        case .report:
            if let seed {
                reportFriend = FriendItem(
                    username: seed.name,
                    displayName: seed.name,
                    avatarURL: seed.avatarURL
                )
            }
        case .doNotDisturb:
            if let seed { mutedIDs.insert(seed.id) }
            // The row now shows a tappable mute glyph; tapping it calls unmute(_:).
        case .hide:
            if let seed {
                hiddenIDs.insert(seed.id)
                Toaster.shared.show(.success("checkmark.circle.fill"), "messages_account_hidden".localized)
            }
        case .moveToGroup:
            groupSeed = seed
            isMovingToGroup = true
        case .addToGroup:
            addGroupSeed = seed
            isAddingToGroup = true
        }
    }

    /// Tapping a row's mute glyph lifts "do not disturb" for it.
    func unmute(_ conversation: MessageConversation) {
        mutedIDs.remove(conversation.id)
    }

    // MARK: - Favourites

    /// Candidates shown in the add-to-favourites picker (the default list).
    var favoriteCandidates: [MessageConversation] { conversations }

    func addToFavorites(_ selected: [MessageConversation]) {
        for conversation in selected where !favorites.contains(where: { $0.id == conversation.id }) {
            favorites.append(conversation)
        }
        isAddingToFavorites = false
        favoriteSeed = nil
        Toaster.shared.show(.success("checkmark.circle.fill"), "messages_added_to_favorites".localized)
    }

    func cancelAddToFavorites() {
        isAddingToFavorites = false
        favoriteSeed = nil
    }

    // MARK: - Move to group

    /// People shown in the first step (pick who to move).
    var groupCandidates: [MessageConversation] { conversations }

    /// Groups shown in the second step (choose the destination group).
    var groupDestinations: [MessageConversation] { MessageConversation.groupSamples }

    /// Final "نقل" tap on the group chooser — close the flow and confirm.
    func finishMoveToGroup() {
        isMovingToGroup = false
        groupSeed = nil
        Toaster.shared.show(.success("checkmark.circle.fill"), "messages_moved_to_group".localized)
    }

    func cancelMoveToGroup() {
        isMovingToGroup = false
        groupSeed = nil
    }

    // MARK: - Add to group

    func addToGroup(_ option: AddToGroupOption) {
        isAddingToGroup = false
        addGroupSeed = nil
        Toaster.shared.show(.success("checkmark.circle.fill"), "messages_added_to_group".localized)
    }

    func cancelAddToGroup() {
        isAddingToGroup = false
        addGroupSeed = nil
    }
}
