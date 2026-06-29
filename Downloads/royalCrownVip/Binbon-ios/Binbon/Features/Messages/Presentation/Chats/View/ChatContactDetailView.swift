//
//  ChatContactDetailView.swift
//  Binbon
//

import Contacts
import SwiftUI

struct ChatContactDetailView: View {

    let name: String
    let phone: String

    @State private var existingContact: CNContact? = nil
    @State private var contactChecked = false
    @State private var isSaving = false
    @State private var savedSuccessfully = false
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColor.chatHeaderGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                headerRow

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        avatarSection
                        phoneCard
                        if contactChecked { saveCard }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .task { await checkExistingContact() }
        .fullScreenCover(isPresented: $showEditView) {
            ChatContactEditView(name: name, phone: phone, existingContact: existingContact)
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Button { dismiss() } label: {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
            }
            .buttonStyle(.plain)

            Spacer()

            Button { showEditView = true } label: {
                Text("contact_edit_button".localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                Text(initials)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Phone card

    private var phoneCard: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("contact_home_label".localized)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
                Text(phone)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
            circleAction(icon: "phone.fill") {
                let digits = "tel://" + phone.filter { $0.isNumber || $0 == "+" }
                if let url = URL(string: digits) { UIApplication.shared.open(url) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
    }

    private func circleAction(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.white.opacity(0.2)).frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save card

    @ViewBuilder
    private var saveCard: some View {
        if existingContact == nil && !savedSuccessfully {
            Button { Task { await saveToContacts() } } label: {
                HStack {
                    if isSaving {
                        ProgressView().tint(.white).frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("save_to_contacts".localized)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.black.opacity(0.22)))
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
        } else {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Text(savedSuccessfully ? "contact_saved".localized : "contact_already_saved".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.black.opacity(0.22)))
        }
    }

    // MARK: - Helpers

    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }

    private func checkExistingContact() async {
        let store = CNContactStore()
        guard (try? await store.requestAccess(for: .contacts)) == true else { contactChecked = true; return }
        let pred = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phone))
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let found = try? store.unifiedContacts(matching: pred, keysToFetch: keys)
        existingContact = found?.first
        contactChecked = true
    }

    private func saveToContacts() async {
        let store = CNContactStore()
        guard (try? await store.requestAccess(for: .contacts)) == true else { return }
        isSaving = true
        let contact = CNMutableContact()
        let parts = name.split(separator: " ", maxSplits: 1)
        contact.givenName = parts.first.map(String.init) ?? name
        if parts.count > 1 { contact.familyName = String(parts[1]) }
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phone))]
        let req = CNSaveRequest(); req.add(contact, toContainerWithIdentifier: nil)
        try? store.execute(req)
        isSaving = false
        savedSuccessfully = true
    }
}
