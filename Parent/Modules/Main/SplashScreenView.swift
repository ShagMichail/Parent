import SwiftUI

struct SplashScreenView: View {
    let textToAnimate = String(localized: "Parental control")
    
    var onAnimationFinished: () -> Void
    
    @State private var displayedText = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.accent.ignoresSafeArea()
            VStack {
                Image("logocontrol")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                
                Text(displayedText)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .onReceive(timer) { _ in
                        animateText()
                    }
            }
        }
    }
    
    private func animateText() {
        if displayedText.count < textToAnimate.count {
            let index = textToAnimate.index(textToAnimate.startIndex, offsetBy: displayedText.count)
            displayedText += String(textToAnimate[index])
        } else {
            timer.upstream.connect().cancel()
            
            onAnimationFinished()
        }
    }
}
