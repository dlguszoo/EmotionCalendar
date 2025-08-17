//
//  HalfCircleShape.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import Foundation
import SwiftUI

struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        return path
    }
}
