//
//  SaveToCollectionSheet.swift
//  Binbon
//

import SwiftUI

struct SaveToCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var collections: [String] = []
    @State private var showNewCollection = false
    @State private var newCollectionName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("save_to_collection".localized)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.appText)

                    Text("saved_to_all_posts".localized)
                        .font(.subheadline)
                        .foregroundStyle(.appText.opacity(0.6))
                }

                Spacer()

                Button("done".localized) { dismiss() }
                    .font(.headline)
                    .foregroundStyle(AppColor.gold)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    newCollectionTile

                    ForEach(collections, id: \.self) { name in
                        collectionTile(name)
                    }
                }
            }

            Spacer()

            Text("see_all_saved".localized)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColor.gold)
                .frame(maxWidth: .infinity)
        }
        .padding(20)
        .alert("new_collection".localized, isPresented: $showNewCollection) {
            TextField("collection_name".localized, text: $newCollectionName)
            Button("cancel".localized, role: .cancel) { newCollectionName = "" }
            Button("create".localized) { addCollection() }
        }
    }

    private var newCollectionTile: some View {
        Button {
            showNewCollection = true
        } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appText.opacity(0.12))
                    .frame(width: 110, height: 110)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .light))
                            .foregroundStyle(.appText)
                    }

                Text("new_collection".localized)
                    .font(.footnote)
                    .foregroundStyle(.appText)
            }
        }
        .buttonStyle(.plain)
    }

    private func collectionTile(_ name: String) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appText.opacity(0.12))
                .frame(width: 110, height: 110)
                .overlay {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.appText.opacity(0.7))
                }

            Text(name)
                .font(.footnote)
                .foregroundStyle(.appText)
                .lineLimit(1)
                .frame(width: 110)
        }
    }

    private func addCollection() {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            collections.append(trimmed)
        }
        newCollectionName = ""
    }
}
