//
//  DynamicSelectorVertically.swift
//  Binbon
//
//  Created by Husayn on 03/06/2026.
//

import SwiftUI

struct DynamicSelectorVertically<Option: DynamicOptionProtocol>: View {
    
    let options: [Option]
    @Binding var selection: Option
    var onSelectionChange: ((Option) -> Void)?
    
    init(options: [Option]? = nil, selection: Binding<Option>, onSelectionChange: ((Option) -> Void)? = nil) {
        self.options = options ?? Array(Option.allCases)
        self._selection = selection
        self.onSelectionChange = onSelectionChange
    }
    
    var body: some View {
        VStack(alignment: .leading,spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                    onSelectionChange?(option)
                } label: {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 1.5)
                                .frame(width: 16, height: 16)
                            
                            if selection == option {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Text(option.title)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.appText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
