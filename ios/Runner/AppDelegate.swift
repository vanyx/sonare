import CoreMotion
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let motionManager = CMMotionManager()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Enregistre les plugins générés
    GeneratedPluginRegistrant.register(with: self)
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let compassChannel = FlutterMethodChannel(name: "com.sonare/compass", binaryMessenger: controller.binaryMessenger)

    // Commence à écouter les mises à jour de direction
    startDeviceMotionUpdates(compassChannel: compassChannel)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Fonction pour démarrer les mises à jour continues de direction
  private func startDeviceMotionUpdates(compassChannel: FlutterMethodChannel) {
    if motionManager.isDeviceMotionAvailable {
      motionManager.deviceMotionUpdateInterval = 0.1 // Intervalle de 100ms
      motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
        guard let data = data else {
          print("Erreur: pas de données de motion disponibles")
          return
        }

        // Récupère la matrice de rotation de l'attitude
        let rotationMatrix = data.attitude.rotationMatrix

        // Calcule l'angle par rapport au nord géographique
        let northDirection = self.calculateNorthDirection(rotationMatrix: rotationMatrix)

        // Envoie la direction en continu à Flutter via le MethodChannel
        compassChannel.invokeMethod("updateDirection", arguments: northDirection)
      }
    } else {
      print("Erreur: Device motion n'est pas disponible.")
    }
  }

  // Fonction pour calculer la direction du nord en utilisant la matrice de rotation
  private func calculateNorthDirection(rotationMatrix: CMRotationMatrix) -> Double {
    // Utilisation des composantes de la matrice pour calculer l'angle par rapport au nord
    let magneticNorth = atan2(rotationMatrix.m22, rotationMatrix.m21) * (180 / Double.pi)
    
    // Corrige l'angle pour s'assurer qu'il est compris entre 0 et 360 degrés
    // let correctedNorth = (magneticNorth + 360).truncatingRemainder(dividingBy: 360)
    
    // return correctedNorth

    return magneticNorth
  }
}
