import Foundation
import RealmSwift

struct NeedData: Codable{
    private let air: Bool
    private let water: Bool
    private let food: Bool
    private let family: Bool
    private let friendship: Bool
    private let intimacy: Bool
    private let clothing: Bool
    private let shelter: Bool
    private let sleep: Bool
    private let reproduction: Bool
    private let personal_security: Bool
    private let employment: Bool
    private let resources: Bool
    private let property: Bool
    private let connection: Bool
    private let health: Bool
    private let respect: Bool
    private let status: Bool
    private let self_esteem: Bool
    private let recognition: Bool
    private let strength: Bool
    private let freedom: Bool
    private let self_actualization: Bool
    
    subscript(needType: String) -> Bool {
        get{
            switch needType{
            case "air": return air
            case "water": return water
            case "food": return food
            case "clothing": return clothing
            case "shelter": return shelter
            case "sleep": return sleep
            case "family": return family
            case "friendship": return friendship
            case "intimacy": return intimacy
            case "reproduction": return reproduction
            case "personal_security": return personal_security
            case "employment": return employment
            case "resources": return resources
            case "property": return property
            case "connection": return connection
            case "health": return health
            case "respect": return respect
            case "status": return status
            case "self_esteem": return self_esteem
            case "recognition": return recognition
            case "strength": return strength
            case "freedom": return freedom
            case "self_actualization": return self_actualization
            default: fatalError("No such need type: \(needType) to retrieve need data")
            }
        }
    }
}

