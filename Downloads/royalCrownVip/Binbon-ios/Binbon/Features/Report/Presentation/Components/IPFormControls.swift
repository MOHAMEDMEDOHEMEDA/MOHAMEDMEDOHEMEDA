//
//  IPFormControls.swift
//  Binbon
//
//  Created by Aya Mashaly on 09/06/2026.
//

import SwiftUI

// MARK: - Radio group (single select)
struct IPRadioGroup: View {
    let options: [String]
    @Binding var selection: String
    var columns: Int = 2
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: columns),
            alignment: .leading,
            spacing: 14
        ) {
            ForEach(options, id: \.self) { option in
                Button { selection = option } label: {
                    HStack(spacing: 8) {
                        Image(systemName: selection == option ? "largecircle.fill.circle" : "circle")
                            .font(.system(size: 16))
                            .foregroundStyle(selection == option ? Color(hex: "#EB7048") : Color(hex: "#B5B5B5"))
                        
                        Text(option)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(AppColor.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct IPTextField: View {
    let placeholder: String
    @Binding var text: String
    var verticalPadding: CGFloat = 12
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(AppColor.textSecondary)
        )
        .font(.system(size: 12))
        .foregroundStyle(AppColor.textPrimary)
        .tint(AppColor.textPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, verticalPadding)
        .background(AppColor.sectionSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.hairline, lineWidth: 1)
        )
    }
}

// MARK: - Multiline text area
struct IPTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 130
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
            
            TextField("", text: $text, axis: .vertical)
                .font(.system(size: 14))
                .foregroundStyle(AppColor.textPrimary)
                .tint(AppColor.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(minHeight: minHeight, alignment: .topLeading)
        }
        .background(AppColor.sectionSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColor.hairline, lineWidth: 1))
    }
}

// MARK: - Segmented
struct IPSegmented: View {
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option
                Button { selection = option } label: {
                    Text(option)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.white)
                        .foregroundStyle(isSelected ? AppColor.textOnAccent : AppColor.textPrimary)
                        .padding(.horizontal, 14)
                    
                        .padding(.vertical, 8)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10).fill(AppColor.buttonGradient)
                            }
                        }
                        .overlay {
                            if !isSelected {
                                RoundedRectangle(cornerRadius: 10).stroke(AppColor.buttonGradient, lineWidth: 1)
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Upload button + hint
struct IPUploadButton: View {
    var title: String
    var hint: String
    var action: () -> Void = {}
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image("upload")
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(AppColor.buttonGradient))
            }
            .buttonStyle(.plain)
            
            Text(hint)
                .font(.system(size: 12))
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Checkbox
struct IPCheckbox: View {
    let text: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button { isOn.toggle() } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isOn ? AnyShapeStyle(AppColor.buttonGradient) : AnyShapeStyle(Color.clear))
                    RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(AppColor.buttonGradient, lineWidth: 1.5)
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 28, height: 28)
                
                Text(text)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Footer
struct IPFooterSection: View {
    let title: String
    let links: [String]
    @State private var expanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                        .rotationEffect(.degrees(expanded ? 0 : -90))
                }
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            
            Divider().overlay(AppColor.hairline)
            
            if expanded {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(links, id: \.self) { link in
                        Button { } label: {
                            Text(link)
                                .font(.system(size: 14))
                                .foregroundStyle(AppColor.textPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
        }
    }
}
