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

/**
 The `AFMultipartFormData` protocol defines the methods supported by the parameter in the block argument of `AFHTTPRequestSerializer -multipartFormRequestWithMethod:URLString:parameters:constructingBodyWithBlock:`.
 */
protocol MultipartFormData {
    /**
     Appends the HTTP header `Content-Disposition: file; filename=#{generated filename}; name=#{name}"` and `Content-Type: #{generated mimeType}`, followed by the encoded file data and the multipart form boundary.
     
     The filename and MIME type for this data in the form will be automatically generated, using the last path component of the `fileURL` and system associated MIME type for the `fileURL` extension, respectively.
     
     @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
     @param name The name to be associated with the specified data. This parameter must not be `nil`.
     @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
     
     @return `YES` if the file data was successfully appended, otherwise `NO`.
     */
    func appendPart(fileURL: URL, name: String, error: Error?) -> Bool

    /**
     Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
     
     @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
     @param name The name to be associated with the specified data. This parameter must not be `nil`.
     @param fileName The file name to be used in the `Content-Disposition` header. This parameter must not be `nil`.
     @param mimeType The declared MIME type of the file data. This parameter must not be `nil`.
     @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
     
     @return `YES` if the file data was successfully appended otherwise `NO`.
     */
    func appendPart(fileURL: URL, name: String, fileName: String, mimeType:String, error: Error?) -> Bool

    /**
     Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the data from the input stream and the multipart form boundary.
     
     @param inputStream The input stream to be appended to the form data
     @param name The name to be associated with the specified input stream. This parameter must not be `nil`.
     @param fileName The filename to be associated with the specified input stream. This parameter must not be `nil`.
     @param length The length of the specified input stream in bytes.
     @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
     */
    func appendPart(inputStream: InputStream, name: String, fileName: String, length: UInt64, mimeType: String)

    /**
     Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
     
     @param data The data to be encoded and appended to the form data.
     @param name The name to be associated with the specified data. This parameter must not be `nil`.
     @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
     @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
     */
    func appendPart(data: Data, name: String, fileName: String, mimeType: String)

    /**
     Appends the HTTP headers `Content-Disposition: form-data; name=#{name}"`, followed by the encoded data and the multipart form boundary.
     
     @param data The data to be encoded and appended to the form data.
     @param name The name to be associated with the specified data. This parameter must not be `nil`.
     */

    func appendPart(data: Data, name: String)


    /**
     Appends HTTP headers, followed by the encoded data and the multipart form boundary.
     
     @param headers The HTTP headers to be appended to the form data.
     @param body The data to be encoded and appended to the form data. This parameter must not be `nil`.
     */
    func appendPart(headers: [String: String], body: Data)

    /**
     Throttles request bandwidth by limiting the packet size and adding a delay for each chunk read from the upload stream.
     
     When uploading over a 3G or EDGE connection, requests may fail with "request body stream exhausted". Setting a maximum packet size and delay according to the recommended values (`kAFUploadStream3GSuggestedPacketSize` and `kAFUploadStream3GSuggestedDelay`) lowers the risk of the input stream exceeding its allocated bandwidth. Unfortunately, there is no definite way to distinguish between a 3G, EDGE, or LTE connection over `NSURLConnection`. As such, it is not recommended that you throttle bandwidth based solely on network reachability. Instead, you should consider checking for the "request body stream exhausted" in a failure block, and then retrying the request with throttled bandwidth.
     
     @param numberOfBytes Maximum packet size, in number of bytes. The default packet size for an input stream is 16kb.
     @param delay Duration of delay each time a packet is read. By default, no delay is set.
     */
    func throttleBandwidthWithPacketSize(numberOfBytes: Int, delay: TimeInterval)

}
