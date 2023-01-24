//
//  Home.swift
//  iPhonePopOvers
//
//  Created by 드즈 on 2023/01/23.
//

import SwiftUI

struct Home: View {
    /// - View Properites

    @State private var ifUp: Bool = false
    @State private var ifDown: Bool = false
    @State private var ifLeft: Bool = false
    @State private var ifRight: Bool = false
    
    @State private var ifWhite: Bool = false
    @State private var ifRed: Bool = false
    @State private var ifBlue: Bool = false
    @State private var ifOrange: Bool = false
    
    @State private var showPopover: Bool = false
    @State private var updateText: Bool = false
    
    var body: some View {
        List {
            Section/*(header: Text("Arrow Direction"))*/ {
                ScrollView(.horizontal/*, showsIndicators: false*/) {
                    HStack(spacing: 20) {
                        ForEach(0..<1) {index in
                            Button("Up") {
                                ifUp.toggle()
                            }
                            Button("Down") {
                                ifDown.toggle()
                            }
                            Button("Left") {
                                ifLeft.toggle()
                            }
                            Button("Right") {
                                ifRight.toggle()
                            }
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 87.5, bottom: 0, trailing: 50))
                //.clipped()
            } header: {
                Text("Arrow Direction")
            }
            .listRowInsets(.init(top: 0, leading: 25, bottom: 0, trailing: 25))
            
            Section /*(header: Text("Background"))*/ {
                ScrollView(.horizontal/*, showsIndicators: false*/) {
                    HStack(spacing: 20) {
                        ForEach(0..<1) { index in
                            Button("Default") {
                                ifWhite.toggle()
                            }
                            Button("Red") {
                                ifRed.toggle()
                            }
                            Button("Blue") {
                                ifBlue.toggle()
                            }
                            Button("Orange") {
                                ifOrange.toggle()
                            }
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 87.5, bottom: 0, trailing: 50))
                //.clipped()
            } header: {
                Text("Background")
            }
            .listRowInsets(.init(top: 0, leading: 25, bottom: 0, trailing: 25))
            
        }
        
        Button("Show Popover") {
            showPopover.toggle()
        }
        .iOSPopover(isPresented: $showPopover, arrowDirection: .down) {
            VStack(spacing: 12) {
                Text("Hello, it's me, \(updateText ? "Updated Popover" : "Popover").")
                Button("Update Text") {
                    updateText.toggle()
                }
                Button("Close Popover") {
                    showPopover.toggle()
                }
            } /// - Console Log : It's simply trying to present the popover again, avoiding that, and updating the view when the SwiftUI has been updated.
            //foregroundColor(.white) - MARK: Error
            .padding(15)
            .frame(width: 250/*225*/)
            /// - You can also Give Full Popover Color like this
            .background {
                if ifWhite {
                    Rectangle()
                        .fill(.white.gradient)
                        .padding(-20)
                }
                if ifRed {
                    Rectangle()
                        .fill(.red.gradient)
                        .padding(-20)
                }
                if ifBlue {
                    Rectangle()
                        .fill(.blue.gradient)
                        .padding(-20)
                }
                if ifOrange {
                    Rectangle()
                        .fill(.orange.gradient)
                        .padding(-20)
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

/// Popovers on iOS are shown as shown as sheets by default; they are only available for macOS and iPadOS, but there is a way to show them, which is will be demostrated in this video.
/// - Enabling Popover for iOS
extension View {
    @ViewBuilder
    func iOSPopover<Content: View>(isPresented: Binding<Bool>, arrowDirection: UIPopoverArrowDirection, @ViewBuilder content: @escaping ()->Content) -> some View {
        self
            .background {
                PopOverController(isPresented: isPresented, arrowDirection: arrowDirection, content: content())
            }
    }
}

/// - Popover Helper
struct PopOverController<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var arrowDirection: UIPopoverArrowDirection
    var content: Content
    /// - View Properties
    @State private var alreadyPresented: Bool = false
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if alreadyPresented {
            /// - Updating SwiftUI View,  when it's Changed
            if let hostingController = uiViewController.presentedViewController as? CustomHostingView<Content> {
                hostingController.rootView = content
                /// - Updating View Size when it's Update
                /// - Or You can define your own size in SwiftUI View
                hostingController.preferredContentSize = hostingController.view.intrinsicContentSize
            }
            
            /// - Close View, if it's toggled Back
            if !isPresented {
                /// - Closing Popover
                uiViewController.dismiss(animated: true) {
                    /// - Restting alreadyPresented State
                    alreadyPresented = false
                }
            }
        } else {
            if isPresented {
                /// Presenting Popover
                let controller = CustomHostingView(rootView: content) /// - Preview Issue
                controller.view.backgroundColor = .clear
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.permittedArrowDirections = arrowDirection
                /// - Connecting Delegate
                controller.presentationController?.delegate = context.coordinator
                /// - We need to Attach the Source View So that it will show Arrow At Correct Position
                controller.popoverPresentationController?.sourceView = uiViewController.view
                /// - Simply Presenting PopOver Controller
                uiViewController.present(controller, animated: true)
            }
        }
    }
    
    /// - Forcing it to show Popover using PresentationDelegate
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        var parent: PopOverController
        init(parent: PopOverController) {
            self.parent = parent
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }
        
        /// - Observing The status of the Popover
        /// - When it's dismissed updating the isPresented State
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
                parent.isPresented = false
        }
        
        /// - When the popover is presented, updating the alreadyPresented State
        func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
            DispatchQueue.main.async {
                self.parent.alreadyPresented = true
            }
        }
    }
}

/// - Custom Hosting Controller for Wrapping to it's SwiftUI View Size
class CustomHostingView<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.intrinsicContentSize
    }
}
