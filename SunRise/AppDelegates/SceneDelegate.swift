import UIKit

class SceneDelegate: UIResponder,
                  UIWindowSceneDelegate {
    
    var window: UIWindow?
    let tabBarController = UITabBarController()
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        window?.makeKeyAndVisible()

        createTabBar()
    }
    
    func createTabBar() {
        let homeNavi = UINavigationController(rootViewController: HomeViewController())
        homeNavi.tabBarItem.image = UIImage(named: "ic-home-white")
        homeNavi.navigationBar.barTintColor = .black
        
        
        let libraryNavi = UINavigationController(rootViewController: LibraryViewController())
        libraryNavi.tabBarItem.image = UIImage(named: "ic-library-white")
        libraryNavi.navigationBar.barTintColor = .black
        libraryNavi.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 25)!,
            NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let searchNavi = UINavigationController(rootViewController: SearchViewController())
        searchNavi.tabBarItem.image = UIImage(named: "ic-search-white")
        searchNavi.navigationBar.barTintColor = .black
        
        tabBarController.viewControllers = [homeNavi, libraryNavi, searchNavi]
        tabBarController.tabBar.tintColor = UIColor(named: "TabBar_Tint")
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.barTintColor = UIColor(named: "TabBar_Background")
        
        window?.rootViewController = tabBarController
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
