import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
    
    var alert: Alert {
        Alert(title: title, message: message, dismissButton: dismissButton)
    }
}

extension AlertItem {
    static let unableToAddPreparation = AlertItem(
        title: Text("Unable to Add Preparation"),
        message: Text("There was an error saving your coffee preparation. Please try again."),
        dismissButton: .default(Text("OK"))
    )
    
    static let unableToUpdatePreparation = AlertItem(
        title: Text("Unable to Update Preparation"),
        message: Text("There was an error updating your coffee preparation. Please try again."),
        dismissButton: .default(Text("OK"))
    )
    
    static let unableToDeletePreparation = AlertItem(
        title: Text("Unable to Delete Preparation"),
        message: Text("There was an error deleting this coffee preparation. Please try again."),
        dismissButton: .default(Text("OK"))
    )
    
    static let unableToLoadPreparations = AlertItem(
        title: Text("Unable to Load Preparations"),
        message: Text("There was an error loading your coffee preparations. Please check your internet connection and try again."),
        dismissButton: .default(Text("OK"))
    )
    
    static let networkError = AlertItem(
        title: Text("Network Error"),
        message: Text("Unable to complete your request at this time. Please check your internet connection."),
        dismissButton: .default(Text("OK"))
    )
} 