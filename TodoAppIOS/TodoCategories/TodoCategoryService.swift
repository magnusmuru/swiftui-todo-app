//
//  TodoCategoryService.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation

class TodoCategoryService {
    
    private var loginService = LoginService()
    let urlString = "https://taltech.akaver.com/api/v1/TodoCategories"
    let categoryUrl: URL
    let jsonDecoder = JSONDecoder()
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Url error!")
        }
        self.categoryUrl = url
    }
    
    private func decodeDataSingle(_ data: Data) -> TodoCategoryEntity  {
        return try! jsonDecoder.decode(TodoCategoryEntity.self, from: data)
    }
    
    private func decodeDataList(_ data: Data) -> TodoCategoryEntities  {
        return try! jsonDecoder.decode(TodoCategoryEntities.self, from: data)
    }
    
    func getAllCategories() async -> TodoCategoryEntities {
        jsonDecoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        let user = await loginService.getLogin()
        if (user == nil) {
            return []
        } else {
            let bearer = "Bearer \(user!.token)"
            var request = URLRequest(url: categoryUrl)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(bearer, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                printJson(data)
                print(response)
                return decodeDataList(data)
            }
            catch {
                print("Error")
            }
        }
        return []
    }
    
    func postDataAsync(_ item: TodoCategoryEntity) async -> TodoCategoryEntity? {
        jsonDecoder.dateDecodingStrategy = .iso8601withTimeZone
        let user = await loginService.getLogin()
        if (user == nil) {
            return nil
        } else {
            guard let encoded = try? JSONEncoder().encode(item) else {
                print("Failed to encode listItem")
                return item
            }
            let bearer = "Bearer \(user!.token)"
            var request = URLRequest(url: categoryUrl)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(bearer, forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            
            do {
                let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
                print(response)
     
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 201 {
                        return decodeDataSingle(data)
                    }
                }
                
                printJson(data)
                
            } catch {
                print("Error")
            }
        }
        
        return nil
    }
    
    func deleteDataAsync(_ id: UUID) async {
        jsonDecoder.dateDecodingStrategy = .iso8601withTimeZone
        let user = await loginService.getLogin()
        if (user == nil) {
            return
        } else {
            let bearer = "Bearer \(user!.token)"
            
            let completeUrl = urlString + "/" + id.uuidString
            
            guard let url = URL(string: completeUrl) else {
                fatalError("URL error")
            }
            print(completeUrl)
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(bearer, forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                        guard error == nil else {
                            print("Error: error calling DELETE")
                            print(error!)
                            return
                        }
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return
                        }
                        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                            print("Error: HTTP request failed")
                            return
                        }
                        do {
                            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                print("Error: Cannot convert data to JSON")
                                return
                            }
                            guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                                print("Error: Cannot convert JSON object to Pretty JSON data")
                                return
                            }
                            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                                print("Error: Could print JSON in String")
                                return
                            }
                            
                            print(prettyPrintedJson)
                        } catch {
                            print("Error: Trying to convert JSON data to string")
                            return
                        }
                    }.resume()
        }
        
        return
    }
    
    func printJson(_ data: Data){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                print("Error: Cannot convert JSON object to Pretty JSON data")
                return
            }
            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                print("Error: Could print JSON in String")
                return
            }
            
            print(prettyPrintedJson)
        } catch {
            print("Error: Trying to convert JSON data to string")
            return
        }
    }
}
