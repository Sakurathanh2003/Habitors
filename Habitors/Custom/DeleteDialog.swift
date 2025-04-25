//
//  DeleteDialog.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import SwiftUI

struct DeleteDialog: View {
    var objectName: String
    var deleteAction: () -> Void
    var cancelAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 56, height: 56)
                    .padding(.top, 20)
                
                Text("Would you like to delete this \(objectName)?")
                    .fontBold(16)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("You cannot undo this action")
                    .fontRegular(12)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                
                HStack {
                    Button {
                        deleteAction()
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.black, lineWidth: 1)
                            .overlay(
                                Text("Delete")
                                    .fontBold(16)
                                    .foregroundStyle(Color("Error"))
                            )
                    }

                    Button {
                        cancelAction()
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.black, lineWidth: 1)
                            .overlay(
                                Text("Cancel")
                                    .fontBold(16)
                                    .foregroundStyle(.black)
                            )
                    }
                }
                .frame(height: 40)
                .padding(.top, 20)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(5)
            .padding(.horizontal, 56)
        }
    }
}

#Preview {
    DeleteDialog(objectName: "kb", deleteAction: { 
        
    }, cancelAction: {  
         
    })
}
