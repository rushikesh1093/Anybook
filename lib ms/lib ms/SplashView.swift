//
//  SplashView.swift
//  AnyBook
//
//  Created by admin86 on 23/04/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack{
            Image("AppLogo").resizable().scaledToFit().frame(width: 600, height: 600)
        }
    }
}

#Preview {
    SplashView()
}
