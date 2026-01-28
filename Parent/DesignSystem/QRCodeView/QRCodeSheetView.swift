//
//  QRCodeSheetView.swift
//  Parent
//
//  Created by Michail Shagovitov on 13.01.2026.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeSheetView: View {
    @Binding var qrCodeImage: UIImage?
    let invitationCode: String
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .padding(.top, 60)
            } else {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 40)
                VStack(spacing: 6) {
                    Text("Не удалось сгенерировать QR-код.")
                    Text("Попробуйте обновить код или используйте цифровой код:")
                    Text("\(invitationCode)")
                }
                .font(.custom("Inter-Regular", size: 20))
                .foregroundColor(.blackText)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview("QR-код сгенерировался") {
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    let mockQRCode = generateQRCode(from: "123456")

    return VStack(spacing: 50) {
        VStack {
            Text("Состояние: QR-код сгенерирован")
                .font(.caption).foregroundColor(.secondary)
            
            QRCodeSheetView(
                qrCodeImage: .constant(mockQRCode),
                invitationCode: "123456"
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    .padding()
}

#Preview("QR-код не сгенерировался") {
    return VStack(spacing: 50) {
        VStack {
            Text("Состояние: Ошибка (qrCodeImage = nil)")
                .font(.caption).foregroundColor(.secondary)
            
            QRCodeSheetView(
                qrCodeImage: .constant(nil),
                invitationCode: "123456"
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        
    }
    .padding()
}
