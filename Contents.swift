import UIKit

let apiKey = "20afcc1cc36bbc6e92f008e9d333dd78"

struct Guest: Codable {
    let success: Bool
    let guestSessionId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case guestSessionId = "guest_session_id"
    }
}

func getGuestSessionId(completion: ((Guest) -> ())?) {
    var components = URLComponents(string: "https://api.themoviedb.org/3/authentication/guest_session/new")!
    
    components.queryItems = [
        URLQueryItem(name: "api_key", value: apiKey)
    ]
    
    let request = URLRequest(url: components.url!)
    
    let task = URLSession.shared.dataTask(with: request) {data, response, error in
        guard let response = response as? HTTPURLResponse, let data = data else {return}
        
        if response.statusCode == 200 {
            let decoder = JSONDecoder()
            let response = try! decoder.decode(Guest.self, from: data)
            
            completion?(response)
        } else {
            print("Error: \(data), HTTP status : \(response.statusCode)")
        }
        
        
    }
    
    task.resume()
}

struct ReviewRequest: Codable {
    let value: Double
}

getGuestSessionId { guest in
    var components = URLComponents(string: "https://api.themoviedb.org/3/movie/339095/rating")!
    
    components.queryItems = [
        URLQueryItem(name: "api_key", value: apiKey),
        URLQueryItem(name: "guest_session_id", value: guest.guestSessionId)
    ]
    
    var request = URLRequest(url: components.url!)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    //let jsonRequest = ["value": 8.5] //pake dictionary
    //let jsonData = try! JSONSerialization.data(withJSONObject: jsonRequest, options: []) //value langsung dari dictionary
    
    let reviewRequest = ReviewRequest(value: 8.5) // dari struct codable
    let jsonData = try! JSONEncoder().encode(reviewRequest) //mengirim data dengan json encode codable
    
    let task = URLSession.shared.uploadTask(with: request, from: jsonData) {data, response, error in
        guard let response = response as? HTTPURLResponse, let data = data else {return}
        
        if response.statusCode == 201 {
            print("Data : \(data)")
        }
    }
    
    task.resume()
    
}


