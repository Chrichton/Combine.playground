// Pointfree #80
// Combine is based upon Protocols
// So you can't instanciate a Publisher and Subscriber
// But you can use the ready made implementations
// Publishers: Future, PassthroughSubject and CurrentValueSubject
// Subscribers: AnySubscriber
// Additionally, subscribers have a method "sink", that acts as a subsciber

import Foundation
import Combine

var count = 0
let iterator = AnyIterator<Int>.init {
    count += 1
    return count
}

Array(iterator.prefix(10))

// Future is a eager Publisher
// Starts working, even if nobody is attached
// "Hello from the future" is printed on creation
// By enclosing it inside Deferred it is converted to a lazy publisher
// A Future is meant to only send one value
// To send more than one value, use a Subject

let aFutureInt = Deferred {
    Future<Int,Never>.init { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Hello from the future")
            callback(.success(42))
            callback(.success(4711))
        }
    }
}

aFutureInt.subscribe(AnySubscriber<Int,Never>.init(
    receiveSubscription: { subscription in
        print("subscription")
//        subscription.cancel()
        subscription.request(.unlimited)
},
    receiveValue: { value -> Subscribers.Demand in
        print("value", value)
        return .unlimited
},
    receiveCompletion: { completion in
        print("completion", completion)
}
))

let cancelable = aFutureInt.sink { value in
    print(value)
}
//cancelable.cancel()

// The two available implementations of Subject are:
// currentValue will send the currentValue to any new subscribers (even without assigning a cancellable
let passthrough = PassthroughSubject<Int,Never>.init()
let currentValue = CurrentValueSubject<Int,Never>.init(42)

let c1 = passthrough.sink { value in
    print("passthrough", value)
}

let c2 = currentValue.sink { value in
    print("currentValue", value)
}

passthrough.send(4711)
currentValue.send(4711)

