# MTJSocketStore

# Intro
SocketStore goal is to provide a template (and later on a  framework) architecture for networked application, it is a facade object that provides APIs for CRUD as well as a connected DataSource which is synced with the cloud. **The example app is a real time chat powered by websockets**.
The facade object rely on several dependencies that can be injected to it. For now I have included concrete implementations of the clients that talks to https://layer.com servers. See #Architecture for design of the store.

## Work In Progress, TODOs:
- **Error handling, no error handling right now as I have no implementations for retries atm**
- **Reachability**, /!\ current store crashes (yes.) and do not work when connection is down /!\
- Typhon for dependency injection
- NSOperation based architecture for dependent tasks
- Retries
- PersistentStack is not using its argument for store and model url
- Provide simpler APIs for creation of entities
- Decouple network representation of entities out of NSManagedObject
- More Tests!
- add generics and nullable for collections
- QoS for GCD

## How to Use it?
An example App is provided for usage of the store. However you need a layerAppID for the example app: you can get one at https://developer.layer.com (or ask me)

## RoadMap
Long term goal is to make it a framework so that you can just use the facade SocketStore object and let you provide only:
- a RESTClient tailored for your server's requirements
- a SocketClient tailored for your server's requirements
- Entities

## Current state of the Architecture
![Alt text](/wiki/SocketStoreArchitecture.png?raw=true "SocketStoreArchitecture")

## Testing
Tests both use Mocking Style and state based tests
