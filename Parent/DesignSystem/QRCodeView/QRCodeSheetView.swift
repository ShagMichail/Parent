//
//  QRCodeSheetView.swift
//  Parent
//
//  Created by Michail Shagovitov on 13.01.2026.
//

import SwiftUI

struct QRCodeSheetView: View {
    @Binding var qrCodeImage: UIImage?
    let invitationCode: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Scan the QR code on the child's device")
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.blackText)
                .padding(.top, 20)
            
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 300)
            } else {
                ContentUnavailableView(
                    "Failed to generate QR code",
                    systemImage: "qrcode.viewfinder"
                )
            }

            Spacer()
        }
        .padding()
    }
}
