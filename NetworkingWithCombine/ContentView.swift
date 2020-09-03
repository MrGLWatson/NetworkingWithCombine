//
//  ContentView.swift
//  NetworkingWithCombine
//
//  Created by Gary Watson on 03/09/2020.
//  Copyright © 2020 Gary Watson. All rights reserved.
//

import SwiftUI
import Combine

struct User: Decodable {
    var id: UUID
    var name: String
    
    static let `default` = User(id: UUID(), name: "Anonymous")
}

struct ContentView: View {
    @State private var requests = Set<AnyCancellable>()
    
    var body: some View {
        Button ("Fetch Data") {
            let url = URL(string: "https://www.hackingwithswift.com/samples/user-24601.json")!
            self.fetch(url, defaultValue: User.default) {
                print($0.name)
            }
        }
    }
//  func fetch(_ url: URL) {
//      URLSession.shared.dataTask(with: url) { data, response, error in
//          if let error = error {
//              print(User.default.name)
//          } else if let data = data {
//              let decoder = JSONDecoder()
//
//              do {
//                  let user = try decoder.decode(User.self, from: data)
//                  print(user.name)
//              } catch {
//                  print(User.default.name)
//              }
//          }
//      }.resume()
//  }
    func fetch<T: Decodable>(_ url: URL, defaultValue: T, completion: @escaping (T) -> Void) {
        let decoder = JSONDecoder()
        
        URLSession.shared.dataTaskPublisher(for: url)
        .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
