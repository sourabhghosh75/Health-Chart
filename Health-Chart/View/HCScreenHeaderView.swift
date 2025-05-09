//
//  HCScreenHeaderView.swift
//  Health-Chart
//
//  Created by Sourabh Ghosh on 10/05/25.
//

import SwiftUI

struct HCScreenHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    var isForListView : Bool? = false
    @State private var selection: Option = .first
    private let options: [Option] = [.first, .second, .third]
    @State private var selection2: Option2 = .first
    private let options2: [Option2] = [.first, .second, .third]
    private let insets: EdgeInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
    private let interSegmentSpacing: CGFloat = 2

    @State private var animationSelection: SegmentedControlAnimation = .default
    private let animationOptions: [SegmentedControlAnimation] = SegmentedControlAnimation.allCases

    @State private var containerCornerRadius: CGFloat = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack {
                if isForListView ?? false {
                    customizableSegmentedControlForList()
                } else {
                    customizableSegmentedControlForDetails()
                }
            }
            .background(Color.white)
            .background {
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .fill(.gray)
                    .stroke(.red, lineWidth: 2)
            }
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .padding()
    }
    private func customizableSegmentedControlForDetails() -> some View {
        CustomizableSegmentedControl(
            selection: $selection,
            options: options,
            selectionView: selectionView(),
            segmentContent: { option, _, isPressed in
                segmentView(title: option.title, imageName: option.imageName, isPressed: isPressed)
                    .colorMultiply(selection == option ? Color.white : .red)
                    .animation(.default, value: selection)
            }
        )
        .segmentAccessibilityValue { index, totalSegmentsCount in
            "Custom accessibility value. Current segment is \(index) of \(totalSegmentsCount)"
        }
        .insets(insets)
        .segmentedControlSlidingAnimation(animationSelection.value)
        .segmentedControl(interSegmentSpacing: interSegmentSpacing)
    }
    private func customizableSegmentedControlForList() -> some View {
        CustomizableSegmentedControl(
            selection: $selection2,
            options: options2,
            selectionView: selectionView(),
            segmentContent: { option, _, isPressed in
                segmentView(title: option.title, imageName: option.imageName, isPressed: isPressed)
                    .colorMultiply(selection2 == option ? Color.white : .red)
                    .animation(.default, value: selection)
            }
        )
        .segmentAccessibilityValue { index, totalSegmentsCount in
            "Custom accessibility value. Current segment is \(index) of \(totalSegmentsCount)"
        }
        .insets(insets)
        .segmentedControlSlidingAnimation(animationSelection.value)
        .segmentedControl(interSegmentSpacing: interSegmentSpacing)
    }
    private func selectionView(color: Color = .red) -> some View {
        color
            .clipShape(RoundedRectangle(cornerRadius: containerCornerRadius - 4))
    }

    private func segmentView(title: String, imageName: String?, isPressed: Bool) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            imageName.map(Image.init(systemName:))
        }
        .foregroundColor(.white.opacity(isPressed ? 0.7 : 1))
        .lineLimit(1)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
    }

    private var animationPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Sliding animation")
                .padding(.horizontal, 2)

            CustomizableSegmentedControl(
                selection: $animationSelection,
                options: animationOptions,
                selectionView: selectionView(color: .red),
                segmentContent: { option, _, isPressed in
                    segmentView(title: option.title, imageName: nil, isPressed: isPressed)
                }
            )
            .insets(insets)
            .segmentedControlContentStyle(.blendMode())
            .segmentedControl(interSegmentSpacing: interSegmentSpacing)
            .clipShape(RoundedRectangle(cornerRadius: containerCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .stroke(.purple)
            )
        }
    }

}

// MARK: - Auxiliary Types

private extension HCScreenHeaderView {

    // MARK: - Option

    enum Option: String, CaseIterable, Identifiable, Hashable {
        case first = "Recent"
        case second = "Weekly"
        case third = "Monthly"

        var id: String { rawValue }
        var title: String { rawValue.capitalized }
        var imageName: String? {
            switch self {
            case .first, .second, .third:
                    return nil
               /* case .second:
                    return "suit.heart.fill"*/
            }
        }
    }
    
    enum Option2: String, CaseIterable, Identifiable, Hashable {
        case first = "Weight"
        case second = "Blood Pressure"
        case third = "Sugar"

        var id: String { rawValue }
        var title: String { rawValue.capitalized }
        var imageName: String? {
            switch self {
            case .first, .second, .third:
                    return nil
               /* case .second:
                    return "suit.heart.fill"*/
            }
        }
    }

    // MARK: - Animation

    enum SegmentedControlAnimation: String, CaseIterable, Identifiable {
        case `default`
        case spring

        var id: String { rawValue }
        var title: String { rawValue.capitalized }

        var value: Animation {
            switch self {
                case .default:
                    return .default
                case .spring:
                    return .interpolatingSpring(stiffness: 180, damping: 15)
            }
        }
    }

}


#Preview {
    HCScreenHeaderView()
}
