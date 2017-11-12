//
//  DockerClient.swift
//  DockerClient
//
//  Created by Valerio Mazzeo on 12/11/2017.
//  Copyright (c) 2017 Valerio Mazzeo. All rights reserved.
//

import Foundation
import Ccurl

public final class DockerClient {

    // MARK: Initialization

    public init(unixSocketPath: String = "/var/run/docker.sock") {
        self.unixSocketPath = unixSocketPath
    }

    // MARK: Accessing Attributes

    public let unixSocketPath: String

    // MARK: Request

    public func respond(to request: URLRequest) throws -> (statusCode: Int, headers: Data?, body: Data?) {

        return try CURLTask(request: request, unixSocketPath: self.unixSocketPath).perform()
    }
}
