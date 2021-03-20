import Foundation

var outputStream: OutputStream! = OutputStream()
Stream.getStreamsToHost(withName: "localhost", port: 9001, inputStream: nil, outputStream: &outputStream)

func notify(_ text: String) {
    _ = text.data(using: .utf8)!.withUnsafeBytes {
        outputStream.write($0, maxLength: text.count)
    }
}

struct Coordinate: Codable, Equatable {
    let x, y, z: Double
}

struct Data: Codable {   
    let coordinates: [Coordinate]
}

func calc(_ text: String) -> Coordinate {
    var (x, y, z) = (0.0, 0.0, 0.0)

    let data = try! JSONDecoder().decode(
        Data.self,
        from: text.data(using: .utf8)!
    )

    for coordinate in data.coordinates {
        x += coordinate.x
        y += coordinate.y
        z += coordinate.z
    }

    let l = Double(data.coordinates.count)
    return Coordinate(x: x / l, y: y / l, z: z / l)
}

let right = Coordinate(x: 2.0, y: 0.5, z: 0.25)
for coordinate in ["{\"coordinates\":[{\"x\":2.0,\"y\":0.5,\"z\":0.25}]}",
                   "{\"coordinates\":[{\"y\":0.5,\"x\":2.0,\"z\":0.25}]}"]
{
    let left = calc(coordinate)
    if left != right {
        fputs("\(left) != \(right)", stderr)
        exit(1)
    }
}

notify("Swift (Codable) \(getpid())")
let results = calc(try! String(contentsOfFile: "/tmp/1.json"))
notify("stop")

print(results)
