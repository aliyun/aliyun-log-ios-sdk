//
// Copyright 2023 aliyun-sls Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#else
import CoreServices
#endif

struct StreamingMultipartFormData : MultipartFormData {
    var request: URLRequest
    var stringEncoding: String.Encoding = .utf8
    var boundary: String?
    var bodyStream: MultipartBodyStream?

    init(urlRequest: URLRequest, stringEncoding: String.Encoding) {
        self.request = urlRequest
        self.stringEncoding = stringEncoding
        self.boundary = HTTPBodyPart.OTelJSBridgeCreateMultipartFormBoundary()
        self.bodyStream = MultipartBodyStream(endoding: stringEncoding)
    }

    func appendPart(fileURL: URL, name: String, error: Error?) -> Bool {
        let fileName = fileURL.lastPathComponent
        let mimeType = HTTPBodyPart.OTelJSBridgeContentTypeForPathExtension(ext: fileURL.pathExtension)
        return self.appendPart(fileURL: fileURL, name: name, fileName: fileName, mimeType: mimeType, error: error)
    }

    func appendPart(fileURL: URL, name: String, fileName: String, mimeType: String, error: Error?) -> Bool{
        if !fileURL.isFileURL {
//            if let error = error {
//                error = NSError.init(domain: "", code: URLError.badURL.rawValue, userInfo: ["": ""]) as Error
//                error.
//            }
            return false
        } else if let checked = try? fileURL.checkResourceIsReachable(), !checked {
            return false
        }

        guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path) else {
            return false
        }

        var mutableHeaders = [String: String]()
        mutableHeaders["Content-Disposition"] = "form-data; name=\"\(name)\"; filename=\"\(fileName)\""
        mutableHeaders["Content-Type"] = mimeType

        let bodyPart = HTTPBodyPart()
        bodyPart.stringEncoding = self.stringEncoding
        bodyPart.headers = mutableHeaders
        bodyPart.boundary = self.boundary
        bodyPart.body = fileURL
        bodyPart.bodyContentLength = fileAttributes[FileAttributeKey.size] as! UInt64
        self.bodyStream?.appendHTTPBodyPart(bodyPart: bodyPart)

        return true
    }

    func appendPart(inputStream: InputStream, name: String, fileName: String, length: UInt64, mimeType: String) {
        var mutableHeaders = [String: String]()
        mutableHeaders["Content-Disposition"] = "form-data; name=\"\(name)\"; filename=\"\(fileName)\""
        mutableHeaders["Content-Type"] = mimeType

        let bodyPart = HTTPBodyPart()
        bodyPart.stringEncoding = self.stringEncoding
        bodyPart.headers = mutableHeaders
        bodyPart.boundary = self.boundary
        bodyPart.body = inputStream
        bodyPart.bodyContentLength = length
        self.bodyStream?.appendHTTPBodyPart(bodyPart: bodyPart)
    }

    func appendPart(data: Data, name: String, fileName: String, mimeType: String) {
        var mutableHeaders = [String: String]()
        mutableHeaders["Content-Disposition"] = "form-data; name=\"\(name)\"; filename=\"\(fileName)\""
        mutableHeaders["Content-Type"] = mimeType

        self.appendPart(headers: mutableHeaders, body: data)
    }

    func appendPart(data: Data, name: String) {
        var mutableHeaders = [String: String]()
        mutableHeaders["Content-Disposition"] = "form-data; name=\"\(name)\""

        self.appendPart(headers: mutableHeaders, body: data)
    }

    func appendPart(headers: [String : String], body: Data) {
        let bodyPart = HTTPBodyPart()
        bodyPart.stringEncoding = self.stringEncoding
        bodyPart.headers = headers
        bodyPart.boundary = self.boundary
        bodyPart.body = body
        bodyPart.bodyContentLength = UInt64(body.count)

        self.bodyStream?.appendHTTPBodyPart(bodyPart: bodyPart)
    }

    func throttleBandwidthWithPacketSize(numberOfBytes: Int, delay: TimeInterval) {
        self.bodyStream?.numberOfBytesInPacket = numberOfBytes
        self.bodyStream?.delay = delay
    }

    mutating func requestByFinalizingMultipartFormData() -> URLRequest {
        guard let bodyStream = bodyStream, !bodyStream.isEmptry() else {
            return self.request
        }

        bodyStream.setInitialAndFinalBoundaries()
        request.httpBodyStream = bodyStream

        request.setValue("multipart/form-data; boundary=\(self.boundary ?? "")", forHTTPHeaderField: "Content-Type")
        request.setValue("\(bodyStream.contentLength)", forHTTPHeaderField: "Content-Length")

        return request
    }
}

//extension Stream {
//    var streamStatus: Stream.Status {
//        return .closed
//    }
//
//    var streamError: Error? {
//        return nil
//    }
//}

// MARK: - MultipartBodyStream -
class MultipartBodyStream: InputStream, StreamDelegate {
    var numberOfBytesInPacket: Int
    var delay: TimeInterval?
    var inputStream: InputStream?
    var contentLength: UInt64 {
        var length: UInt64 = 0
        for bodyPart in httpBodyParts {
            length += bodyPart.contentLength
        }
        return length
    }
//    use isEmpty() func instead
//    var empty: Bool = true

    private var stringEncoding: String.Encoding
    private var httpBodyParts: [HTTPBodyPart]
    private var httpBodyPartEnumerator: EnumeratedSequence<[HTTPBodyPart]>.Iterator?
    private var currentHTTPBodyPart: HTTPBodyPart?
    private var outputStream: OutputStream?
    private var buffer: Data?

    private var streamStatusCopy: Stream.Status = .notOpen
    private var streamErrorCopy: Error?
    private weak var streamDelegate: StreamDelegate?

    override var streamStatus: Stream.Status {
        streamStatusCopy
    }

    override var streamError: Error? {
        streamErrorCopy
    }

    override var delegate: StreamDelegate? {
        get {
            streamDelegate
        }
        set {
            streamDelegate = newValue ?? self
        }
    }

    init(endoding: String.Encoding) {
        self.stringEncoding = endoding
        self.httpBodyParts = [HTTPBodyPart]()
        self.numberOfBytesInPacket = Int.max

        super.init(data: Data())
//        TODO: how to use delegate ??
//        super.delegate = self
    }

    func setInitialAndFinalBoundaries() {
        if httpBodyParts.count > 0 {
            for bodyPart in httpBodyParts {
                bodyPart.hasInitialBoundary = false
                bodyPart.hasFinalBoundary = false
            }

            httpBodyParts.first?.hasInitialBoundary = true
            httpBodyParts.last?.hasFinalBoundary = true
        }
    }

    func appendHTTPBodyPart(bodyPart: HTTPBodyPart) {
        httpBodyParts.append(bodyPart)
    }

    func isEmptry() -> Bool {
        return self.httpBodyParts.count == 0
    }

// MARK: - InputStream
    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        if self.streamStatusCopy == .closed {
            return 0
        }

        var totalNumberOfBytesRead: Int = 0
        while Int(totalNumberOfBytesRead) < min(len, self.numberOfBytesInPacket) {
            if let currentHTTPBodyPart = currentHTTPBodyPart, currentHTTPBodyPart.hasBytesAvailable() {
                let maxLength: Int = min(len, self.numberOfBytesInPacket) - totalNumberOfBytesRead
                let numberOfBytesRead = currentHTTPBodyPart.read(buffer: &buffer[totalNumberOfBytesRead],
                                                                 maxLength: maxLength)
                if -1 == numberOfBytesRead {
                    self.streamErrorCopy = currentHTTPBodyPart.inputStream?.streamError
                    break
                } else {
                    totalNumberOfBytesRead += numberOfBytesRead
                    if let delay = delay, delay > 0.0 {
                        Thread.sleep(forTimeInterval: delay)
                    }
                }
            } else {
                self.currentHTTPBodyPart = httpBodyPartEnumerator?.next()?.element
                guard let _ = self.currentHTTPBodyPart else {
                    break
                }
            }
        }

        return totalNumberOfBytesRead
    }

    override func getBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length len: UnsafeMutablePointer<Int>) -> Bool {
        return false
    }

    override var hasBytesAvailable: Bool {
        return self.streamStatusCopy == Stream.Status.open
    }

// MARK: - Stream
    override func open() {
        if self.streamStatusCopy == .open {
            return
        }

        self.streamStatusCopy = .open
        self.setInitialAndFinalBoundaries()
        self.httpBodyPartEnumerator = self.httpBodyParts.enumerated().makeIterator()
    }

    override func close() {
        self.streamStatusCopy = .closed
    }

    override func property(forKey key: Stream.PropertyKey) -> Any? {
        return nil
    }

    override func setProperty(_ property: Any?, forKey key: Stream.PropertyKey) -> Bool {
        return false
    }

    override func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
        // empty
    }

    override func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
        // empty
    }

// MARK: Undocumented CFReadStream Bridged Methods
    func _scheduleInCFRunLoop(runLoop: RunLoop, forMode mode: String) {
            print("call _scheduleInCFRunLoop")
    }

    func _unscheduleFromCFRunLoop(runLoop: CFRunLoop, forMode aMode:CFString) {

    }

    func _setCFClientFlags(inFlags: CFOptionFlags, callback: CFReadStreamClientCallBack!,
                           context: UnsafeMutablePointer<CFStreamClientContext>) -> Bool {
        return false
    }
}

// MARK: - HTTPBodyPart -
class HTTPBodyPart {
    static let MultipartFormCRLF = "\r\n";
    @inline(__always) static func OTelJSBridgeCreateMultipartFormBoundary() -> String{
        return "Boundary+\(String(format: "%08X", arc4random()))\(String(format: "%08X", arc4random()))"
    }

    @inline(__always) static func OTelJSBridgeMultipartFormInitialBoundary(boundary: String) -> String {
        return "--\(boundary)\(HTTPBodyPart.MultipartFormCRLF)"
    }

    @inline(__always) static func OTelJSBridgeMultipartFormEncapsulationBoundary(boundary: String) -> String {
        return "\(HTTPBodyPart.MultipartFormCRLF)--\(boundary)\(HTTPBodyPart.MultipartFormCRLF)"
    }

    @inline(__always) static func OTelJSBridgeMultipartFormFinalBoundary(boundary: String) -> String {
        return "\(HTTPBodyPart.MultipartFormCRLF)--\(boundary)--\(HTTPBodyPart.MultipartFormCRLF)"
    }

    @inline(__always) static func OTelJSBridgeContentTypeForPathExtension(ext: String) -> String {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as NSString, nil) else {
            return "application/octet-stream"
        }

        guard let mimetype = UTTypeCopyPreferredTagWithClass(uti.takeRetainedValue(), kUTTagClassMIMEType) else {
            return "application/octet-stream"
        }

        return mimetype.takeRetainedValue() as String
    }

    var stringEncoding: String.Encoding = .utf8
    var headers: [String: String]?
    var boundary : String?
    var body: Any?
    var bodyContentLength: UInt64 = 0

    var _inputStream: InputStream?
    var inputStream: InputStream? {
        if let _ = _inputStream {
            return _inputStream
        }

        if let b = body as? Data {
            _inputStream = InputStream.init(data: b)
        } else if let b = body as? URL {
            _inputStream = InputStream.init(url: b)
        } else if let b = body as? InputStream {
            _inputStream = b
        } else {
            _inputStream = InputStream.init(data: Data())
        }

        return _inputStream
    }

    var hasInitialBoundary: Bool = false
    var hasFinalBoundary: Bool = false

    var bytesAvailable: Bool {
        return self.hasBytesAvailable()
    }
    var contentLength: UInt64 {
        var length: UInt64 = 0;
        if let boundary = boundary {
            let encapsulationBoundaryData = (self.hasInitialBoundary ? HTTPBodyPart.OTelJSBridgeMultipartFormInitialBoundary(boundary: boundary):  HTTPBodyPart.OTelJSBridgeMultipartFormEncapsulationBoundary(boundary: boundary)).data(using: stringEncoding)
            if let _ = encapsulationBoundaryData {
                length += UInt64(encapsulationBoundaryData!.count)
            }
        }

        if let headersData = self.stringForHeaders()?.data(using: stringEncoding) {
            length += UInt64(headersData.count);
        }

        length += bodyContentLength

        if self.hasInitialBoundary, let boundary = self.boundary, let closingBoundaryData = HTTPBodyPart.OTelJSBridgeMultipartFormFinalBoundary(boundary: boundary).data(using: self.stringEncoding) {
            length += UInt64(closingBoundaryData.count)
        }

        return length;
    }

    // extension
    var phase: HTTPBodyPartReadPhase?
    // _inputStream
    var phaseReadOffset: UInt64 = 0

    init() {
        let _ = self.transitionToNextPhase()
    }

    deinit {
        guard let _ = _inputStream else {
            return
        }
        _inputStream?.close()
        _inputStream = nil
    }

    func stringForHeaders() -> String? {
        guard let headers = headers else {
            return nil
        }

        var headerString = String()

        for field in headers.keys {
            headerString.append("\(field): \(headers[field] ?? "")\(HTTPBodyPart.MultipartFormCRLF)")
        }
        headerString.append(HTTPBodyPart.MultipartFormCRLF)

        return headerString
    }

    func hasBytesAvailable() -> Bool {
        // Allows `read:maxLength:` to be called again if `OTelJSBridgeMultipartFormFinalBoundary` doesn't fit into the available buffer
        if phase == .FinalBoundaryPhase {
            return true
        }

        guard let inputStream = self.inputStream else {
            return false
        }

        switch inputStream.streamStatus {
        case Stream.Status.notOpen:
            fallthrough
        case Stream.Status.opening:
            fallthrough
        case Stream.Status.open:
            fallthrough
        case Stream.Status.reading:
            fallthrough
        case Stream.Status.writing:
            return true
        case Stream.Status.atEnd:
            fallthrough
        case Stream.Status.closed:
            fallthrough
        case Stream.Status.error:
            fallthrough
        default:
            return false
        }
    }

    func read(buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
        var totalNumberOfBytesRead: Int = 0;

        if (phase == .EncapsulationBoundaryPhase) {
            if let boundary = boundary {
                if let encapsulationBoundaryData = (self.hasInitialBoundary ? HTTPBodyPart.OTelJSBridgeMultipartFormInitialBoundary(boundary: boundary) : HTTPBodyPart.OTelJSBridgeMultipartFormEncapsulationBoundary(boundary: boundary)).data(using: self.stringEncoding) {
                    totalNumberOfBytesRead += self.readData(data: encapsulationBoundaryData,
                                                            intoBuffer: &buffer[totalNumberOfBytesRead],
                                                            maxLength: (maxLength - Int(totalNumberOfBytesRead)))
                }

            }
        }

        if (phase == .HeaderPhase) {
            if let headersData = self.stringForHeaders()?.data(using: self.stringEncoding) {
                totalNumberOfBytesRead += self.readData(data: headersData,
                                                        intoBuffer: &buffer[totalNumberOfBytesRead],
                                                        maxLength: (maxLength - Int(totalNumberOfBytesRead)))
            }
        }

        if (phase == .BodyPhase) {
            if let inputStream: InputStream = self.inputStream {
                let numberOfBytesRead = inputStream.read(&buffer[totalNumberOfBytesRead],
                                                         maxLength: (maxLength - Int(totalNumberOfBytesRead)))
                if -1 == numberOfBytesRead {
                    return -1
                } else {
                    totalNumberOfBytesRead += numberOfBytesRead
                    if inputStream.streamStatus == .atEnd || inputStream.streamStatus == .closed || inputStream.streamStatus == .error {
                        let _ = self.transitionToNextPhase()
                    }
                }
            }
        }

        if (phase == .FinalBoundaryPhase) {
            if let boundary = boundary {
                if let closingBoundaryData = self.hasInitialBoundary ? HTTPBodyPart.OTelJSBridgeMultipartFormFinalBoundary(boundary: boundary).data(using: self.stringEncoding) : Data() {
                    totalNumberOfBytesRead += self.readData(data: closingBoundaryData,
                                                            intoBuffer: &buffer[totalNumberOfBytesRead],
                                                            maxLength: (maxLength - Int(totalNumberOfBytesRead)))
                }
            }
        }

        return totalNumberOfBytesRead;
    }

    func readData(data: Data, intoBuffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
        let range: Range = Range.init(NSMakeRange(Int(self.phaseReadOffset), min(data.count - Int(phaseReadOffset), maxLength)))!

        data.copyBytes(to: intoBuffer, from: range)
        self.phaseReadOffset += UInt64(range.count);

        if Int(phaseReadOffset) >= data.count {
            let _ = self.transitionToNextPhase()
        }

        return range.count;
    }

    func transitionToNextPhase() -> Bool {
        if !Thread.current.isMainThread {
            let _ = DispatchQueue.main.sync {
                self.transitionToNextPhase()
            }
            return true
        }

        switch phase {
        case .EncapsulationBoundaryPhase:
            phase = .HeaderPhase
        case .HeaderPhase:
            self.inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.common)
            self.inputStream?.open()
            phase = .BodyPhase
        case .BodyPhase:
            self.inputStream?.close()
            phase = .FinalBoundaryPhase
        case .FinalBoundaryPhase:
            fallthrough
        default:
            phase = .EncapsulationBoundaryPhase
        }
        self.phaseReadOffset = 0
        return true
    }

    //    #pragma mark - NSCopying
    //
    //    - (instancetype)copyWithZone:(NSZone *)zone {
    //        OTelJSBridgeHTTPBodyPart *bodyPart = [[[self class] allocWithZone:zone] init];
    //
    //        bodyPart.stringEncoding = self.stringEncoding;
    //        bodyPart.headers = self.headers;
    //        bodyPart.bodyContentLength = self.bodyContentLength;
    //        bodyPart.body = self.body;
    //        bodyPart.boundary = self.boundary;
    //
    //        return bodyPart;
    //    }
    //
    //    @end
}

// MARK: - HTTPBodyPartReadPhase
extension HTTPBodyPart {
    enum HTTPBodyPartReadPhase : Int {
        case EncapsulationBoundaryPhase = 1
        case HeaderPhase  = 2
        case BodyPhase  = 3
        case FinalBoundaryPhase = 4
    }
}

// MARK: - compare
extension HTTPBodyPart : Equatable {
    static func == (lhs: HTTPBodyPart, rhs: HTTPBodyPart) -> Bool {
        return lhs.stringEncoding == rhs.stringEncoding &&
        lhs.headers == rhs.headers &&
        lhs.boundary == rhs.boundary &&
        lhs.bodyContentLength == rhs.bodyContentLength &&
        lhs.inputStream == rhs.inputStream &&
        lhs.hasInitialBoundary == rhs.hasInitialBoundary &&
        lhs.hasFinalBoundary == rhs.hasFinalBoundary &&
        lhs.bytesAvailable == rhs.bytesAvailable &&
        lhs.contentLength == rhs.contentLength &&
        lhs.phase == rhs.phase &&
        lhs.phaseReadOffset == rhs.phaseReadOffset
    }
}
