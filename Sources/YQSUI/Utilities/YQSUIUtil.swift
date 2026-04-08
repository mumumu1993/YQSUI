//
//  YQSUIUtil.swift
//  YQSUI
//
//  Created by yumumu on 2026/1/8.
//

import SwiftUI

// 获取屏幕尺寸的实用工具
public struct YQSUIScreen {
    public static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    public static var height: CGFloat {
        UIScreen.main.bounds.height
    }
}

// 获取应用主窗口的实用工具
public struct YQSUIMainWindow {
    public static var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
}


public extension String {
    //String获取多语言
    func yqs_localized(comment:String = "") -> String {
        NSLocalizedString(self, comment: "")
    }
}

public extension UIApplication {
    //获取当前window
    var currentWindow: UIWindow? {
        let connectedScenes = self.connectedScenes
        let windowScene = connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        if let windowScene = windowScene {
            return windowScene.windows.first { $0.isKeyWindow }
        }
        //如果没有找到前台活跃的windowScene，则返回第一个keyWindow
        if let window = windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        //如果没有keyWindow，则获取第一个window
        if let window = windows.first {
            return window
        }
        //如果没有window，则返回nil
        return nil
    }
    
    //获取当前的rootViewController
    var currentRootViewController: UIViewController? {
        //获取当前window
        guard let window = currentWindow else {
            return nil
        }
        //获取rootViewController
        return window.rootViewController
    }
    
    //获取当前的topViewController
    var currentTopViewController: UIViewController? {
        //获取当前的rootViewController
        guard let rootViewController = currentRootViewController else {
            return nil
        }
        //递归查找最顶层的ViewController
        return findTopViewController(from: rootViewController)
    }
    
    private func findTopViewController(from viewController: UIViewController) -> UIViewController {
        //如果viewController是UINavigationController，则获取其visibleViewController
        if let navigationController = viewController as? UINavigationController {
            let visibleViewController = navigationController.visibleViewController
            //如果visibleViewController不为nil，则递归查找
            if let visibleViewController = visibleViewController {
                return findTopViewController(from: visibleViewController)
            }
        }
        //如果viewController是UITabBarController，则获取其selectedViewController
        if let tabBarController = viewController as? UITabBarController {
            let selectedViewController = tabBarController.selectedViewController
            //如果selectedViewController不为nil，则递归查找
            if let selectedViewController = selectedViewController {
                return findTopViewController(from: selectedViewController)
            }
        }
        //如果viewController有presentedViewController，则递归查找
        if let presentedViewController = viewController.presentedViewController {
            return findTopViewController(from: presentedViewController)
        }
        //否则，返回当前的viewController
        return viewController
    }
    
    //获取当前的NV
    var currentNavigationController: UINavigationController? {
        //获取当前的rootViewController
        guard let rootViewController = currentRootViewController else {
            return nil
        }
        //如果rootViewController是UINavigationController，则直接返回
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController
        }
        //否则，递归查找子控制器中的UINavigationController
        return findNavigationController(in: rootViewController)
    }
    
    private func findNavigationController(in viewController: UIViewController) -> UINavigationController? {
        //如果viewController是UINavigationController，则直接返回
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        //如果viewController有子控制器，则递归查找
        for child in viewController.children {
            if let navigationController = findNavigationController(in: child) {
                return navigationController
            }
        }
        //如果没有找到，则返回nil
        return nil
    }
}

//获取安全区域高度
public struct YQSUISafeArea {
    //顶部安全区高度
    public static var top: CGFloat {
        UIApplication.shared.currentWindow?.safeAreaInsets.top ?? 0
    }
    
    //底部安全区高度
    public static var bottom: CGFloat {
        UIApplication.shared.currentWindow?.safeAreaInsets.bottom ?? 0
    }
}

//给视图添加点按背景颜色变化效果
/// 例如：.modifier(YQSUIPressEffect(normalColor: .white, pressedColor: .gray))
public struct YQSUIPressEffect: ViewModifier {
    @State private var isPressed = false
    var normalColor: Color
    var pressedColor: Color
    
    public func body(content: Content) -> some View {
        content
            .background(isPressed ? pressedColor : normalColor)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            isPressed = false
                        }
                    }
            ).simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation {
                            isPressed = true
                        }
                    })
                    .onEnded({ _ in
                        withAnimation {
                            isPressed = false
                        }
                    })
            )
    }
}

//添加加点按背景颜色变化效果便捷方法
public extension View {
    func yqsUIPressEffect(normalColor: Color = .clear, pressedColor: Color = .black.opacity(0.3)) -> some View {
        self.modifier(YQSUIPressEffect(normalColor: normalColor, pressedColor: pressedColor))
    }
}

//给视图添加无视安全区 + 隐藏导航栏效果
public struct YQSUIFullScreenModifier: ViewModifier {
    var alignment: Alignment = .top
    
    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: alignment)
        } else {
            // Fallback on earlier versions
            content
                .ignoresSafeArea()
                .navigationBarHidden(true)
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: alignment)
        }
    }
}

//添加全屏效果的便捷方法
public extension View {
    func yqsUIFullScreen(alignment:Alignment = .top) -> some View {
        self.modifier(YQSUIFullScreenModifier(alignment: alignment))
    }
}
