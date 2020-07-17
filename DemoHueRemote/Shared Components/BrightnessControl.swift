//
//  BrightnessControl.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 14/07/2020.
//

import SwiftUI

struct BrightnessControl: View {
    @Binding var value: Float

    var body: some View {
        HStack {
            Image(systemName: "sun.max")
            Slider(
                value: $value,
                in: 0...255,
                step: 1.0
            )
        }
    }
}

struct BrightnessControl_Previews: PreviewProvider {
    static var previews: some View {
        BrightnessControl(value: .constant(100.0))
    }
}
