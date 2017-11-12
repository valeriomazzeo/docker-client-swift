# docker-client-swift

![Swift](https://img.shields.io/badge/swift-4.0.2-orange.svg)
![Platform](https://img.shields.io/badge/platform-OSX-lightgrey.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

A lightweight Swift client for the Docker Remote API.

## Get Started

Since `docker-client-swift` depends on `curl`  (7.40.0 and higher), make sure it is available on the system.

Mac OS X already includes a version of `curl`, on Linux you'll have to install it through a system package manager.

For example on Ubuntu: `apt-get install libcurl4-openssl-dev`

## Usage

```Swift

// Create a client instance, optionally specifying the unix socket
let docker = DockerClient(unixSocketPath: "/var/run/docker.sock")

// Create an URLRequest
let url = URL(string: "http:/1.32/containers/json")!
let request = URLRequest(url: url)

let result = try docker.respond(to: request)

print(result.statusCode)
// => 200

print(String(data: result.headers!, encoding: .utf8))
// => HTTP/1.1 200 OK Cache-Control: private ...

print(String(bytes: result.body!, encoding: .utf8))
// => { "Hostname": "", "Domainname": "", "User": "", ...
```

## License

Copyright (c) 2017 Valerio Mazzeo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
