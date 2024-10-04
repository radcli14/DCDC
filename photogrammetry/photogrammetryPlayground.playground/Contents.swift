import Foundation
import RealityKit

// User specification for the directory relative to this file with the images
let baseUrl = URL(
    fileURLWithPath: "/Users/radcli14/Documents/code/DCDC/photogrammetry",
    isDirectory: true
)
let modelName = "puppyAugust"
let outputFileFormat = ".usdz"
let outputFileDetail: [PhotogrammetrySession.Request.Detail] = [.reduced, .medium, .full]

// Setup paths and URL's for the sources
let pictureUrl = baseUrl.appendingPathComponent(modelName)

// Setup paths and URL's for the outputs
func makeUrl(
    for detail: PhotogrammetrySession.Request.Detail,
    _ amountOfUnderscoresToPrepend: Int = 0
) -> URL {
    let prefix = String(repeating: "_", count: amountOfUnderscoresToPrepend)
    let suffix = outputFileFormat == ".usdz" ? ".usdz" : ""
    return pictureUrl.appendingPathComponent("\(prefix)\(detail)\(suffix)")
}
let outputFileUrls = outputFileDetail.map { detail in
    makeUrl(for: detail)
}

// Initiate a session using a folder where we have stored images
let session = try! PhotogrammetrySession(
    input: pictureUrl,
    configuration: PhotogrammetrySession.Configuration()
)

// Connect the output stream to dispatch messages
Task {
    for try await output in session.outputs {
        switch output {
        case .requestProgress(let request, let fraction):
            print("Request progress: \(fraction)")
        case .requestComplete(let request, let result):
            if case .modelFile(let url) = result {
                print("Request result output at \(url).")
            }
        case .requestError(let request, let error):
            print("Error: \(request) error = \(error)")
        case .processingComplete:
            print("Completed!")
        default:
            break
        }
    }
}

// Create requests
let requests: [PhotogrammetrySession.Request] = (0 ..< outputFileDetail.count).map { k in
        .modelFile(url: outputFileUrls[k],  detail: outputFileDetail[k], geometry: .init(bounds: BoundingBox(min: simd_float3(x: -10, y: -10, z: -10), max: simd_float3(x: 10, y: 20, z: 10))))
}

// If files already exist at the intended output location, rename them
let fileManager = FileManager.default
for k in 0 ..< outputFileDetail.count {
    var n = 0
    while fileManager.fileExists(atPath: makeUrl(for: outputFileDetail[k], n).path) {
        n += 1
    }
    if n > 0 {
        try! fileManager.moveItem(at: outputFileUrls[k], to: makeUrl(for: outputFileDetail[k], n))
    }
    if outputFileFormat != ".usdz" && !fileManager.fileExists(atPath: outputFileUrls[k].path) {
        try! fileManager.createDirectory(at: outputFileUrls[k], withIntermediateDirectories: true)
    }
    
}

// Generate reduced and medium model
for request in requests {
    do {
        try session.process(requests: [request])
    } catch {
        print("An error occured: \(error)")
    }
}
