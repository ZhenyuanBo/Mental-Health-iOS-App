import Foundation

struct NeedActivityData: Codable{
    private let air: Int
    private let water: Int
    private let food: Int
    private let family: Int
    private let friendship: Int
    private let clothing: Int
    private let shelter: Int
    private let sleep: Int
    private let reproduction: Int
    private let personal_security: Int
    private let employment: Int
    private let resources: Int
    private let property: Int
    private let health: Int
    private let respect: Int
    private let status: Int
    private let self_esteem: Int
    private let recognition: Int
    private let strength: Int
    private let freedom: Int
    private let self_actualization: Int
    
    subscript(needType: String) -> Int {
        get {
            switch needType{
            case "air": return air
            case "water": return water
            case "food": return food
            case "clothing": return clothing
            case "shelter": return shelter
            case "sleep": return sleep
            case "family": return family
            case "friendship": return friendship
            case "reproduction": return reproduction
            case "personal_security": return personal_security
            case "employment": return employment
            case "resources": return resources
            case "property": return property
            case "health": return health
            case "respect": return respect
            case "status": return status
            case "self_esteem": return self_esteem
            case "recognition": return recognition
            case "strength": return strength
            case "freedom": return freedom
            case "self_actualization": return self_actualization
            default: fatalError("No such need type: \(needType)")
            }
        }
    }
}
