//
//  PositionValueView.swift
//  CashAppCodingChallenge
//
//  Created by Jah Morris-Jones on 7/23/24.
//

import SwiftUI

/// A reusable view for the label-value pair display.
///
/// Used as a view for multiple properties of a position (ie: in `DetailView`).
struct LabelValueView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}
