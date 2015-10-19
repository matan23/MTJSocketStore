# MTJSocketStore

# Intro
SocketStore goal is to provide a template architecture for networked application, it provides a facade that rely on several dependencies that can be injected to the store. For now I have included concrete implementations of the clients that use https://layer.com. see #Architecture

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
Long term goal is for you to only provide:
- RESTClient a tailored for your server's requirements
- SocketClient a tailored for your server's requirements
- Entities

## Current state of the Architecture
![Alt text](/wiki/SocketStoreArchitecture.png?raw=true "SocketStoreArchitecture")

## Testing
Tests both use Mocking Style and state based tests
