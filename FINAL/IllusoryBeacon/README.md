# Illusory Beacon

<p align="center">
  <img src="https://user-images.githubusercontent.com/3107872/70857891-8c045300-1ebc-11ea-997c-b3c10b87110b.png" />
  Share and discover a bigger world together.
</p>

## Features

* User authentication and profile management, avatar service provided by [Gravatar](https://gravatar.com/)
* Predict current location by camera frame (Apache MXNet LocationNet model behind the scenes). Location data will be stored via latitude and longitude
* Users can post text and images at current location. The posted texts and images under current location will display via AR when another user comes to the same location
* Update AR scene when detected user is moving. When a user selects and image or text in the AR scene, it will be displayed full screen for the user to view and explore
* High performance backend server by [Sanic](https://github.com/huge-success/sanic) + [Tortoise ORM](https://github.com/tortoise/tortoise-orm) (Communication protocol: WebSocket, Database: PostgreSQL)
* User interface built by SwiftUI and Combine
* Containerized backend with [Docker Compose
](https://github.com/docker/compose)

## Environment

* Xcode 11.2.1
* Swift 5.1.2

## Elements

* SwiftUI
* Core Motion
* Core Image
* Core ML
* Core Location
* ARKit
* CryptoKit
* SceneKit

## Dependencies

* [Starscream](https://github.com/daltoniam/Starscream)
* [Introspect](https://github.com/timbersoftware/SwiftUI-Introspect)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [Just](https://github.com/dduan/Just)

The dependencies are managed by [Swift Package Manager](https://swift.org/package-manager/).

## Extra Dependencies

Please download the [RN1015k500.mlmodel](https://s3.amazonaws.com/aws-bigdata-blog/artifacts/RN1015k500/RN1015k500.mlmodel) to the [Resources](/IllusoryBeacon/Resources) directory. It is too large (284.41 MB) and exceeds GitHub's file size limit of 100.00 MB.

## Backend

### Build

```shell
docker-compose build
```

### Run in background

```shell
docker-compose up -d
```

