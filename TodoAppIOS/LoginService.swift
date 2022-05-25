//
//  LoginService.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation

class LoginService {
    let urlString = "https://taltech.akaver.com/api/v1/Account/Login"
    let email = "magtest@test.com"
    let password = "Password123!"
    let jsonDecoder = JSONDecoder()
    let loginUrl: URL
    
    init() {
        guard let loginUrl = URL(string: urlString) else {
            fatalError("Url error!")
        }
        self.loginUrl = loginUrl
    }
    
    private func decodeDataSingle(_ data: Data) -> LoginResponseEntity  {
        return try! jsonDecoder.decode(LoginResponseEntity.self, from: data)
    }
    
    func getLogin() async -> LoginResponseEntity? {
        let loginInfo = LoginRequestContent(email: email, password: password)
        guard let encoded = try? JSONEncoder().encode(loginInfo) else {
            print("Failed to encode loginInfo")
            return nil
        }
        
        var request = URLRequest(url: loginUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
            print(response)
 
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    return decodeDataSingle(data)
                }
            }
            
            printJson(data)
            
        } catch {
            print("Error")
        }
        
        return nil
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
