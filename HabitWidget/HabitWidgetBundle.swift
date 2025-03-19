//
//  HabitWidgetBundle.swift
//  HabitWidget
//
//  Created by Vũ Thị Thanh on 18/3/25.
//

import WidgetKit
import SwiftUI

@main
struct HabitWidgetBundle: WidgetBundle {
    
    var body: some Widget {
        HabitWidget()
        HabitWidgetLiveActivity()
    }
}
