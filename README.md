# MTJSocketStore

# Intro
SocketStore goal is to provide a template (and later on a  framework) architecture for networked application, it is a facade object that provides APIs for CRUD as well as a connected DataSource which is synced with the cloud. **The example app is a real time chat powered by websockets**.
The facade object rely on several dependencies that can be injected to it. For now I have included concrete implementations of the clients that use https://layer.com. see #Architecture

## Work In Progress, TODOs:
- **Reachability**, /!\ current store crashes (yes.) and do not work when connection is down /!\
- Retries
- OperationQueues for retries
- Provide simpler APIs for creation of entities
- Move the network representation of entities out of NSManagedObject
- More Tests!

## How to Use it?
An example App is provided for usage of the store.

## RoadMap
Long term goal is to make it a framework so that you can just use the facade SocketStore object and let you provide only:
- RESTClient a tailored for your server's requirements
- SocketClient a tailored for your server's requirements
- Entities

## Current state of the Architecture
![Alt text](/wiki/SocketStoreArchitecture.png?raw=true "SocketStoreArchitecture")

## Testing
Tests both use Mocking Style and state based tests
