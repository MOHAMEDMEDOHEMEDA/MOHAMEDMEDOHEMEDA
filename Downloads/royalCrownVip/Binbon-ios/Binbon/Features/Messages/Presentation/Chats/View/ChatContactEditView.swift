//
//  ChatContactEditView.swift
//  Binbon
//

import Contacts
import SwiftUI

struct ChatContactEditView: View {

    private let existingContact: CNContact?

    @State private var firstName: String
    @State private var lastName: String
    @State private var phoneNumber: String
    @State private var syncToPhone: Bool = true
    @State private var showDiscardAlert = false
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    init(name: String, phone: String, existingContact: CNContact? = nil) {
        self.existingContact = existingContact
        _firstName   = State(initialValue: existingContact?.givenName  ?? {
            let p = name.split(separator: " ", maxSplits: 1)
            return p.first.map(String.init) ?? name
        }())
        _lastName    = State(initialValue: existingContact?.familyName ?? {
            let p = name.split(separator: " ", maxSplits: 1)
            return p.count > 1 ? String(p[1]) : ""
        }())
        _phoneNumber = State(initialValue: existingContact?.phoneNumbers.first?.value.stringValue ?? phone)
    }

    private var isValid: Bool { !firstName.trimmingCharacters(in: .whitespaces).isEmpty && !phoneNumber.isEmpty }

    var body: some View {
        ZStack {
            AppColor.chatHeaderGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                headerRow

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        nameCard
                        phoneEditCard
                        if existingContact != nil { syncCard }
                        if existingContact != nil { deleteCard }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .confirmationDialog(
            "contact_discard_message".localized,
            isPresented: $showDiscardAlert,
            titleVisibility: .visible
        ) {
            Button("contact_discard_changes".localized, role: .destructive) { dismiss() }
            Button("contact_keep_editing".localized,    role: .cancel)       {}
        }
        .alert("contact_delete_title".localized, isPresented: $showDeleteAlert) {
            Button("contact_delete_confirm".localized, role: .destructive) {
                Task { await deleteFromPhone(); dismiss() }
            }
            Button("cancel".localized, role: .cancel) {}
        } message: {
            Text("contact_delete_message".localized)
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Button { showDiscardAlert = true } label: {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("contact_edit_title".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Task { await saveToPhone(); dismiss() }
            } label: {
                Circle()
                    .fill(isValid ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(isValid ? AppColor.gradientTop : Color.white.opacity(0.35))
                    }
            }
            .buttonStyle(.plain)
            .disabled(!isValid)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Name card

    private var nameCard: some View {
        VStack(spacing: 0) {
            styledField(placeholder: "contact_first_name".localized, text: $firstName)
            Divider().background(Color.white.opacity(0.15)).padding(.leading, 16)
            styledField(placeholder: "contact_last_name".localized, text: $lastName)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
    }

    // MARK: - Phone card

    private var phoneEditCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("contact_phone_label".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, alignment: .leading)
                Spacer()
                Text("contact_country_placeholder".localized)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.6))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().background(Color.white.opacity(0.15)).padding(.leading, 16)

            HStack {
                Text("contact_home_label".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, alignment: .leading)
                TextField(
                    "",
                    text: $phoneNumber,
                    prompt: Text("contact_phone_placeholder".localized).foregroundColor(.white.opacity(0.45))
                )
                .keyboardType(.phonePad)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(.white)
                Spacer()
                if isValid {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
    }

    // MARK: - Sync card

    private var syncCard: some View {
        HStack {
            Text("contact_sync_to_phone".localized)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: $syncToPhone)
                .tint(AppColor.gradientTop)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
    }

    // MARK: - Delete card

    private var deleteCard: some View {
        Button { showDeleteAlert = true } label: {
            HStack {
                Text("contact_delete".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.destructiveRed)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.22))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func styledField(placeholder: String, text: Binding<String>) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(placeholder).foregroundColor(.white.opacity(0.45))
        )
        .font(.system(size: 15))
        .foregroundStyle(.white)
        .tint(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func saveToPhone() async {
        guard syncToPhone else { return }
        let store = CNContactStore()
        guard (try? await store.requestAccess(for: .contacts)) == true else { return }
        let req = CNSaveRequest()

        if let existing = existingContact {
            // Fetch with all needed keys, then update
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            guard let full = try? store.unifiedContact(withIdentifier: existing.identifier, keysToFetch: keys),
                  let mutable = full.mutableCopy() as? CNMutableContact else { return }
            mutable.givenName  = firstName.trimmingCharacters(in: .whitespaces)
            mutable.familyName = lastName.trimmingCharacters(in: .whitespaces)
            mutable.phoneNumbers = [CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phoneNumber))]
            req.update(mutable)
        } else {
            let contact = CNMutableContact()
            contact.givenName  = firstName.trimmingCharacters(in: .whitespaces)
            contact.familyName = lastName.trimmingCharacters(in: .whitespaces)
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phoneNumber))]
            req.add(contact, toContainerWithIdentifier: nil)
        }

        try? store.execute(req)
    }

    private func deleteFromPhone() async {
        guard let existing = existingContact else { return }
        let store = CNContactStore()
        guard (try? await store.requestAccess(for: .contacts)) == true else { return }
        let keys = [CNContactGivenNameKey] as [CNKeyDescriptor]
        guard let full = try? store.unifiedContact(withIdentifier: existing.identifier, keysToFetch: keys),
              let mutable = full.mutableCopy() as? CNMutableContact else { return }
        let req = CNSaveRequest()
        req.delete(mutable)
        try? store.execute(req)
    }
}
