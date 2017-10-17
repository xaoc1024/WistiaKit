//
//  WistiaClient.swift
//  WistiaKit
//
//  Created by Daniel Spinosa on 10/17/17.
//

import Foundation

public enum WistiaError: Error {
    case unknown
    case other(Error?)
    case apiErrors([[String:String]])
    case decodingError(DecodingError)
    case badResponse(Data)
}

//Every response has either a data or an error as the top level object
//They may have both in the case of a partial error (ie. request X,Y,Z but response only includes X and Y)
public struct WistiaResponse<DataType: Codable>: Codable {
    public let data: DataType?
    public let errors: [[String: String]]?
}

public class WistiaClient {

    fileprivate static let APIBase = URL(string: "https://api.wistia.com/v2/")
    //fileprivate static let APIUploadURL = "https://upload.wistia.com"

    public let token: String?
    public let session: URLSession

    open static var `default`: WistiaClient = {
        return WistiaClient()
    }()

    public init(token: String? = nil, sessionConfiguration: URLSessionConfiguration? = nil) {
        let config = sessionConfiguration ?? URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
        self.token = token
    }

    public func get<T>(_ path: String, parameters: [String: String] = [:], completionHandler: @escaping ((T?, WistiaError?) ->())) where T: Codable {
        var params = parameters
        if token != nil {
            params["api_password"] = token
        }

        let urlRequest = getRequest(for: path, with: params)

        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            self.handleDataTaskResult(data: data, urlResponse: urlResponse, error: error, completionHandler: completionHandler)
            }.resume()
    }

    //public func post<T>
    //public func put<T>
    //public func patch<T>
    //public func delete<T>
}

//MARK: - Result Handling
extension WistiaClient {

    internal func handleDataTaskResult<T>(data: Data?, urlResponse: URLResponse?, error: Error?, completionHandler: @escaping ((T?, WistiaError?) ->())) where T: Codable {

        if let error = error {
            completionHandler(nil, WistiaError.other(error))
        }
        else if let data = data {
            let jsonDecoder = JSONDecoder()
            do {
                let decoded = try jsonDecoder.decode(WistiaResponse<T>.self, from: data)
                if let apiErrors = decoded.errors {
                    completionHandler(nil, WistiaError.apiErrors(apiErrors))
                }
                else if let data = decoded.data {
                    completionHandler(data, nil)
                }
                else {
                    completionHandler(nil, WistiaError.badResponse(data))
                }
            } catch let error as DecodingError {
                completionHandler(nil, WistiaError.decodingError(error))
            } catch {
                completionHandler(nil, WistiaError.other(error))
            }
        }
        else {
            completionHandler(nil, WistiaError.unknown)
        }
    }

}

//MARK: - URL Building
extension WistiaClient {

    private func getRequest(for path: String, with parameters: [String: String]) -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: path, relativeTo: WistiaClient.APIBase)!)
        var urlComponents = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)!

        let queryParams = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        //XXX: May need to URL encode (escape) these params
        urlComponents.percentEncodedQuery = queryParams
        urlRequest.url = urlComponents.url

        return urlRequest
    }

}

