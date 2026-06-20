import WidgetKit
import SwiftUI

@main
struct HabiWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabiWidget()
        HabiStreakLiveActivity()
    }
}
