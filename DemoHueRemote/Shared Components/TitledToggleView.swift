//
//  TitledToggleView.swift
//  HueLightsController
//
//  Created by Anil Puttabuddhi on 10/07/2020.
//

import SwiftUI

struct TitledToggleView: View {
    @Binding var isOn: Bool
    let isEnabled: Bool
    let imageName: String
    let title: String
    let subTitle: String?

    var body: some View {
        Toggle(isOn: $isOn) {
            Image(systemName: imageName)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                if subTitle != nil {
                    Text(subTitle!).font(.caption)
                }
            }
        }
        .disabled(!isEnabled)
        .toggleStyle(SwitchToggleStyle(tint: .accentColor)) }
}

struct TitledToggleView_Previews: PreviewProvider {
    static var previews: some View {
        TitledToggleView(isOn: .constant(true),
                         isEnabled: true,
                         imageName: "scissors",
                         title: "Some Title",
                         subTitle: "Some caption")
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
