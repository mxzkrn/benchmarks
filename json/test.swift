import Foundation

var outputStream: OutputStream! = OutputStream()
Stream.getStreamsToHost(withName: "localhost", port: 9001, inputStream: nil, outputStream: &outputStream)

func notify(_ text: String) {
    _ = text.data(using: .utf8)!.withUnsafeBytes {
        outputStream.write($0, maxLength: text.count)
    }
}

struct Coordinate: Equatable {
    let x, y, z: Double
}

func calc(_ text: String) -> Coordinate {
    var (x, y, z) = (0.0, 0.0, 0.0)

    let data = try! JSONSerialization.jsonObject(
        with: text.data(using: .utf8)!,
        options: [] 
    ) as! [String: Any]
    
    let coordinates = data["coordinates"]! as! [[String: Any]] 
    for coordinate in coordinates {
        x += coordinate["x"]! as! Double
        y += coordinate["y"]! as! Double
        z += coordinate["z"]! as! Double
    }
    
    let l = Double(coordinates.count)

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

notify("Swift \(getpid())")
let results = calc(try! String(contentsOfFile: "/tmp/1.json"))
notify("stop")

print(results)
