//
//  ReelSendToSheet.swift
//  Binbon
//
//  Full-height "Send to" picker presented from a reel. Shows a searchable
//  grid of people the reel can be sent to directly, distinct from the
//  bottom share sheet (copy link / external apps).
//

import SwiftUI

struct ReelSendToSheet: View {
    var onSend: ((ShareContact) -> Void)? = nil

    @StateObject private var viewModel: ShareViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    init(onSend: ((ShareContact) -> Void)? = nil) {
        self.onSend = onSend
        _viewModel = StateObject(wrappedValue: ShareViewModel())
    }

    private var people: [ShareContact] {
        guard !query.isEmpty else { return viewModel.contacts }
        return viewModel.contacts.filter {
            $0.username.localizedCaseInsensitiveContains(query) ||
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            header

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 28) {
                    ForEach(people) { person in
                        personCell(person)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.shareSheetGradient)
        .task { viewModel.load() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image("CommentClose")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("close".localized))

            searchField
        }
        .padding(.horizontal, 20)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            TextField("", text: $query, prompt: Text("search".localized).foregroundColor(.white.opacity(0.8)))
                .foregroundStyle(.white)
                .tint(.white)

            Image("share-search")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            Capsule().fill(Color.white.opacity(0.18))
        )
    }

    private func personCell(_ person: ShareContact) -> some View {
        Button {
            onSend?(person)
            dismiss()
        } label: {
            VStack(spacing: 10) {
                ImageView(person.avatarURL)
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())

                Text("@\(person.username)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Color.gray
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ReelSendToSheet()
        }
}
