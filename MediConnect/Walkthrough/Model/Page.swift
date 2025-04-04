
import SwiftUI

enum Page: String, CaseIterable {
    case page1 = "cross.fill"
    case page2 = "person.crop.circle.badge.checkmark.fill"
    case page3 = "video.fill"
    case page4 = "waveform.path.ecg"
    
    var title: String {
        switch self {
        case .page1: "Welcome to MedCare."
        case .page2: "Easy for everyone."
        case .page3: "Connect with doctors."
        case .page4: "Your health, simplified"
        }
    }
    
    var subTitle: String {
        switch self {
        case .page1: "AI-powered symptom analysis for personalized care."
        case .page2: "Designed for simple navigation."
        case .page3: "Speak with doctors for precise care."
        case .page4: "MedCare allows you to make informed decisions anytime."
        }
    }
    
    var index: CGFloat {
        switch self {
        case .page1: 0
        case .page2: 1
        case .page3: 2
        case .page4: 3
        }
    }
    
    var nextPage: Page {
        let index = Int(self.index) + 1
        if index < 4 {
            return Page.allCases[index]
        }
        return self
    }
    

    var previousPage: Page {
        let index = Int(self.index) - 1
        if index >= 0 {
            return Page.allCases[index]
        }
        
        return self
    }
}
