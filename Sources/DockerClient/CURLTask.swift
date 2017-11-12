//
//  CURLTask.swift
//  DockerClient
//
//  Created by Valerio Mazzeo on 12/11/2017.
//  Copyright (c) 2017 Valerio Mazzeo. All rights reserved.
//

import Foundation
import Ccurl

public final class CURLTask {

    // MARK: Initialization

    public init(request: URLRequest, unixSocketPath: String? = nil) throws {

        // CURL initialization
        guard let curl = curl_easy_init() else {
            throw Error.curlInitializationError
        }

        self.curl = curl
        self.request = request

        // Configure unix socket path if present
        if let unixSocketPath = unixSocketPath {

            guard let cUnixSocketPath = unixSocketPath.cString(using: .utf8) else {
                throw Error.invalidUnixSocketPath
            }

            curl_easy_setopt_cstr(curl, CURLOPT_UNIX_SOCKET_PATH, cUnixSocketPath)
        }

        curl_easy_setopt_long(curl, CURLOPT_NOSIGNAL, 1)

        // Header / Write / Read data
        let opaqueSelf = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        curl_easy_setopt_void(curl, CURLOPT_HEADERDATA, opaqueSelf)
        curl_easy_setopt_void(curl, CURLOPT_WRITEDATA, opaqueSelf)
        curl_easy_setopt_void(curl, CURLOPT_READDATA, opaqueSelf)

        // Header function
        curl_easy_setopt_func(curl, CURLOPT_HEADERFUNCTION) { a, size, num, p in

            let curlTask = Unmanaged<CURLTask>.fromOpaque(p!).takeUnretainedValue()

            guard let bytes = a?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }

            let count = size * num

            for index in 0..<count {
                curlTask.headerBytes.append(bytes[index])
            }

            return count
        }

        // Write function
        curl_easy_setopt_func(curl, CURLOPT_WRITEFUNCTION) { a, size, num, p in

            let curlTask = Unmanaged<CURLTask>.fromOpaque(p!).takeUnretainedValue()

            guard let bytes = a?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }

            let count = size * num

            for index in 0..<count {
                curlTask.bodyBytes.append(bytes[index])
            }

            return count
        }

        // Read function
        curl_easy_setopt_func(curl, CURLOPT_READFUNCTION) { _, _, _, _ in
            return 0
        }
    }

    // MARK: Accessing Attributes

    public let request: URLRequest

    public private(set) var response: HTTPURLResponse? = nil

    // MARK: CURL

    private let curl: UnsafeMutableRawPointer

    private typealias SList = UnsafeMutablePointer<curl_slist>

    private var slistMap: [UInt32: SList] = [:]

    private var headerBytes: [UInt8] = []

    private var bodyBytes: [UInt8] = []

    public func perform() throws -> (statusCode: Int, headers: Data?, body: Data?) {

        guard self.response == nil else {
            throw Error.improperCURLTaskUse
        }

        guard let url = self.request.url?.absoluteString else {
            throw URLError(.badURL)
        }

        // HTTP Method
        switch self.request.httpMethod?.uppercased() {
        case .some("GET"), .none:
            curl_easy_setopt_int64(self.curl, CURLOPT_HTTPGET, 1)
        case .some("POST"):
            curl_easy_setopt_int64(self.curl, CURLOPT_POST, 1)
        case .some("HEAD"):
            curl_easy_setopt_int64(self.curl, CURLOPT_NOBODY, 1)
        default:
            curl_easy_setopt_cstr(self.curl, CURLOPT_CUSTOMREQUEST, self.request.httpMethod)
        }

        // URL
        curl_easy_setopt_cstr(self.curl, CURLOPT_URL, url)

        // HTTP Headers
        if let allHTTPHeaderFields = self.request.allHTTPHeaderFields, !allHTTPHeaderFields.isEmpty {

            for header in allHTTPHeaderFields {
                self.appendSList(key: CURLOPT_HTTPHEADER.rawValue, value: "\(header.key): \(header.value)")
            }
        }

        self.slistMap.forEach { key, value in
            curl_easy_setopt_slist(self.curl, CURLoption(rawValue: key), value)
        }

        // HTTP Body
        if let httpBody = self.request.httpBody {

            let bytes = [UInt8](httpBody)

            curl_easy_setopt_long(self.curl, CURLOPT_POSTFIELDSIZE_LARGE, bytes.count)
            curl_easy_setopt_void(self.curl, CURLOPT_COPYPOSTFIELDS, UnsafeMutableRawPointer(mutating: bytes))
        }

        // Perform request
        let code = curl_easy_perform(self.curl)

        guard code == CURLE_OK else {
            throw Error.curl(String(validatingUTF8: curl_easy_strerror(code))!)
        }

        let statusCode: Int = try self.getInfo(CURLINFO_RESPONSE_CODE)

        return (
            statusCode: statusCode,
            headers: self.headerBytes.isEmpty ? nil : Data(self.headerBytes),
            body: self.bodyBytes.isEmpty ? nil : Data(self.bodyBytes)
        )
    }

    private func appendSList(key: UInt32, value: String) {

        let old = self.slistMap[key]
        let new = curl_slist_append(old, value)

        self.slistMap[key] = new
    }

    private func getInfo(_ info: CURLINFO) throws -> Int {

        var result: Int = 0

        let code = curl_easy_getinfo_long(self.curl, info, &result)

        guard code == CURLE_OK else {
            throw Error.curl(String(validatingUTF8: curl_easy_strerror(code))!)
        }

        return result
    }

    private func getInfo(_ info: CURLINFO) throws -> Double {

        var result: Double = 0

        let code = curl_easy_getinfo_double(self.curl, info, &result)

        guard code == CURLE_OK else {
            throw Error.curl(String(validatingUTF8: curl_easy_strerror(code))!)
        }

        return result
    }

    private func getInfo(_ info: CURLINFO) throws -> String {

        var result: UnsafePointer<Int8>? = nil

        let code = curl_easy_getinfo_cstr(self.curl, info, &result)

        guard code == CURLE_OK, let someResult = result, let string = String(validatingUTF8: someResult) else {
            throw Error.curl(String(validatingUTF8: curl_easy_strerror(code))!)
        }

        return string
    }

    // MARK: Finalization

    deinit {
        curl_easy_cleanup(self.curl)

        self.slistMap.forEach { _, ptr in
            curl_slist_free_all(ptr)
        }

        self.slistMap = [:]
    }
}

public extension CURLTask {

    public enum Error: Swift.Error {
        case curlInitializationError
        case invalidUnixSocketPath
        case improperCURLTaskUse
        case curl(String)
    }
}
