//
//  AppleMusicManager.swift
//  swiftTest
//
//  Created by Max Brodheim on 8/11/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation

import Foundation
import StoreKit
import UIKit

class AppleMusicManager {
  
  // MARK: Types
  
  /// The completion handler that is called when an Apple Music Catalog Search API call completes.
//  typealias CatalogSearchCompletionHandler = (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void
  
  /// The completion handler that is called when an Apple Music Get User Storefront API call completes.
  typealias GetUserStorefrontCompletionHandler = (_ storefront: String?, _ error: Error?) -> Void
  
  // MARK: Properties
  
  /// The instance of `URLSession` that is going to be used for making network calls.
  lazy var urlSession: URLSession = {
    // Configure the `URLSession` instance that is going to be used for making network calls.
    let urlSessionConfiguration = URLSessionConfiguration.default
    
    return URLSession(configuration: urlSessionConfiguration)
  }()
  
  /// The storefront id that is used when making Apple Music API calls.
  var storefrontID: String?
  
  func fetchDeveloperToken() -> String? {
    
    // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD
    let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ikw4RE05UjJDWVYifQ.eyJpc3MiOiJMTlEyMllGOFVCIiwiaWF0IjoxNTAyMjk2MjE4LCJleHAiOjE1MDIzMzk0MTh9.l7rUYrfD4JJ0XTfclJC8R990cu-YfJoM5yVFGXL0MwPPrjgx1aPFB-YGWU2R6pMknItAd7f_WhlwjmldBZlk7w"
    return developerAuthenticationToken
  }
  
  // MARK: General Apple Music API Methods
  
//  func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
//
//    guard let developerToken = fetchDeveloperToken() else {
//      fatalError("Developer Token not configured. See README for more details.")
//    }
//
//    let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
//
//    let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
//      guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
//        completion([], error)
//        return
//      }
//
//      do {
//        let mediaItems = try self.processMediaItemSections(from: data!)
//        completion(mediaItems, nil)
//
//      } catch {
//        fatalError("An error occurred: \(error.localizedDescription)")
//      }
//    }
//
//    task.resume()
//  }
  
  func performAppleMusicStorefrontsLookup(regionCode: String, completion: @escaping GetUserStorefrontCompletionHandler) {
    guard let developerToken = fetchDeveloperToken() else {
      fatalError("Developer Token not configured. See README for more details.")
    }
    
    let urlRequest = AppleMusicRequestFactory.createStorefrontsRequest(regionCode: regionCode, developerToken: developerToken)
    
    let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
      guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        completion(nil, error)
        return
      }
      
      do {
        let identifier = try self?.processStorefront(from: data!)
        completion(identifier, nil)
      } catch {
        fatalError("An error occurred: \(error.localizedDescription)")
      }
    }
    
    task.resume()
  }
  
  // MARK: Personalized Apple Music API Methods
  
  func performAppleMusicGetUserStorefront(userToken: String, completion: @escaping GetUserStorefrontCompletionHandler) {
    guard let developerToken = fetchDeveloperToken() else {
      fatalError("Developer Token not configured.  See README for more details.")
    }
    
    let urlRequest = AppleMusicRequestFactory.createGetUserStorefrontRequest(developerToken: developerToken, userToken: userToken)
    
    let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
      guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        let error = NSError(domain: "AppleMusicManagerErrorDomain", code: -9000, userInfo: [NSUnderlyingErrorKey: error!])
        
        completion(nil, error)
        
        return
      }
      
      do {
        
        let identifier = try self?.processStorefront(from: data!)
        
        completion(identifier, nil)
      } catch {
        fatalError("An error occurred: \(error.localizedDescription)")
      }
    }
    
    task.resume()
  }
  
//  func processMediaItemSections(from json: Data) throws -> [[MediaItem]] {
//    guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
//      let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
//        throw SerializationError.missing(ResponseRootJSONKeys.results)
//    }
//
//    var mediaItems = [[MediaItem]]()
//
//    if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
//
//      if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
//        let songMediaItems = try processMediaItems(from: dataArray)
//        mediaItems.append(songMediaItems)
//      }
//    }
//
//    if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
//
//      if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
//        let albumMediaItems = try processMediaItems(from: dataArray)
//        mediaItems.append(albumMediaItems)
//      }
//    }
//
//    return mediaItems
//  }
  
//  func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
//    let songMediaItems = try json.map { try MediaItem(json: $0) }
//    return songMediaItems
//  }
  
  func processStorefront(from json: Data) throws -> String {
    guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
      let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
        throw SerializationError.missing(ResponseRootJSONKeys.data)
    }
    
    guard let identifier = data.first?[ResourceJSONKeys.identifier] as? String else {
      throw SerializationError.missing(ResourceJSONKeys.identifier)
    }
    
    return identifier
  }
}

struct AppleMusicRequestFactory {
  
  // MARK: Types
  
  /// The base URL for all Apple Music API network calls.
  static let appleMusicAPIBaseURLString = "api.music.apple.com"
  
  /// The Apple Music API endpoint for requesting a list of recently played items.
  static let recentlyPlayedPathURLString = "/v1/me/recent/played"
  
  /// The Apple Music API endpoint for requesting a the storefront of the currently logged in iTunes Store account.
  static let userStorefrontPathURLString = "/v1/me/storefront"
  
  static func createSearchRequest(with term: String, countryCode: String, developerToken: String) -> URLRequest {
    
    // Create the URL components for the network call.
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
    urlComponents.path = "/v1/catalog/\(countryCode)/search"
    
    let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
    let urlParameters = ["term": expectedTerms,
                         "limit": "10",
                         "types": "songs,albums"]
    
    var queryItems = [URLQueryItem]()
    for (key, value) in urlParameters {
      queryItems.append(URLQueryItem(name: key, value: value))
    }
    
    urlComponents.queryItems = queryItems
    
    // Create and configure the `URLRequest`.
    
    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = "GET"
    
    urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
    
    return urlRequest
  }
  
  static func createStorefrontsRequest(regionCode: String, developerToken: String) -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
    urlComponents.path = "/v1/storefronts/\(regionCode)"
    
    // Create and configure the `URLRequest`.
    
    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = "GET"
    
    urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
    
    return urlRequest
  }
  
  static func createRecentlyPlayedRequest(developerToken: String, userToken: String) -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
    urlComponents.path = AppleMusicRequestFactory.recentlyPlayedPathURLString
    
    // Create and configure the `URLRequest`.
    
    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = "GET"
    
    urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
    urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
    
    return urlRequest
  }
  
  static func createGetUserStorefrontRequest(developerToken: String, userToken: String) -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
    urlComponents.path = AppleMusicRequestFactory.userStorefrontPathURLString
    
    // Create and configure the `URLRequest`.
    
    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = "GET"
    
    urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
    urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
    
    return urlRequest
  }
}

/// Keys related to the `Response Root` JSON object in the Apple Music API.
struct ResponseRootJSONKeys {
  static let data = "data"
  
  static let results = "results"
}

/// Keys related to the `Resource` JSON object in the Apple Music API.
struct ResourceJSONKeys {
  static let identifier = "id"
  
  static let attributes = "attributes"
  
  static let type = "type"
}

/// The various keys needed for parsing a JSON response from the Apple Music Web Service.
struct ResourceTypeJSONKeys {
  static let songs = "songs"
  
  static let albums = "albums"
}

enum SerializationError: Error {
  case missing(String)
}
