//
//  AddParticipantDrawer.swift
//  Binbon
//

import SwiftUI

/// Sliding drawer overlay for inviting participants into an active video call.
/// Presented as a bottom sheet at 66% screen height. Dismiss by dragging down.
struct AddParticipantDrawer: View {

    let contacts: [CallContact]
    var onAdd: (CallContact) -> Void = { _ in }
    @State private var searchText = ""

    private var filtered: [CallContact] {
        guard !searchText.isEmpty else { return contacts }
        return contacts.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.top, 12)
                .padding(.horizontal, 19)
                .padding(.bottom, 4)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { contact in
                        CallContactItem(contact: contact, onAdd: { onAdd(contact) })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .presentationDetents([.fraction(0.66)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(27)
        .presentationBackground(AppColor.backgroundGradient)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.65))

            TextField(
                "voice_call_add_participant_search".localized,
                text: $searchText
            )
            .font(.system(size: 12))
            .foregroundStyle(.white)
            .tint(.white)
        }
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(
            Capsule(style: .continuous)
                .fill(.white.opacity(0.15))
        )
    }
}

// MARK: - Preview

#Preview("Add Participant Drawer") {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            AddParticipantDrawer(contacts: CallContact.mockList)
        }
}
