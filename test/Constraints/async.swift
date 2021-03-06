// RUN: %target-typecheck-verify-swift 

// REQUIRES: concurrency

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func doAsynchronously() async { }
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func doSynchronously() { }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func testConversions() async {
  let _: () -> Void = doAsynchronously // expected-error{{invalid conversion from 'async' function of type '() async -> ()' to synchronous function type '() -> Void'}}
  let _: () async -> Void = doSynchronously // okay
}

// Overloading
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
@available(swift, deprecated: 4.0, message: "synchronous is no fun")
func overloadedSame(_: Int = 0) -> String { "synchronous" }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func overloadedSame() async -> String { "asynchronous" }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func overloaded() -> String { "synchronous" }
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func overloaded() async -> Double { 3.14159 }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
@available(swift, deprecated: 4.0, message: "synchronous is no fun")
func overloadedOptDifference() -> String { "synchronous" }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func overloadedOptDifference() async -> String? { nil }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func testOverloadedSync() {
  _ = overloadedSame() // expected-warning{{synchronous is no fun}}

  let _: String? = overloadedOptDifference() // expected-warning{{synchronous is no fun}}

  let _ = overloaded()
  let fn = {
    overloaded()
  }
  let _: Int = fn // expected-error{{value of type '() -> String'}}

  let fn2 = {
    print("fn2")
    _ = overloaded()
  }
  let _: Int = fn2 // expected-error{{value of type '() -> ()'}}

  let fn3 = {
    await overloaded()
  }
  let _: Int = fn3 // expected-error{{value of type '() async -> Double'}}

  let fn4 = {
    print("fn2")
    _ = await overloaded()
  }
  let _: Int = fn4 // expected-error{{value of type '() async -> ()'}}
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func testOverloadedAsync() async {
  _ = await overloadedSame() // no warning

  let _: String? = await overloadedOptDifference() // no warning

  let _ = await overloaded()
  let _ = overloaded()
  // expected-error@-1:11{{expression is 'async' but is not marked with 'await'}}{{11-11=await }}
  // expected-note@-2:11{{call is 'async'}}


  let fn = {
    overloaded()
  }
  let _: Int = fn // expected-error{{value of type '() -> String'}}

  let fn2 = {
    print("fn2")
    _ = overloaded()
  }
  let _: Int = fn2 // expected-error{{value of type '() -> ()'}}

  let fn3 = {
    await overloaded()
  }
  let _: Int = fn3 // expected-error{{value of type '() async -> Double'}}

  let fn4 = {
    print("fn2")
    _ = await overloaded()
  }
  let _: Int = fn4 // expected-error{{value of type '() async -> ()'}}
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func takesAsyncClosure(_ closure: () async -> String) -> Int { 0 }
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func takesAsyncClosure(_ closure: () -> String) -> String { "" }

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func testPassAsyncClosure() {
  let a = takesAsyncClosure { await overloadedSame() }
  let _: Double = a // expected-error{{convert value of type 'Int'}}

  let b = takesAsyncClosure { overloadedSame() } // expected-warning{{synchronous is no fun}}
  let _: Double = b // expected-error{{convert value of type 'String'}}
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
struct FunctionTypes {
  var syncNonThrowing: () -> Void
  var syncThrowing: () throws -> Void
  var asyncNonThrowing: () async -> Void
  var asyncThrowing: () async throws -> Void

  mutating func demonstrateConversions() {
    // Okay to add 'async' and/or 'throws'
    asyncNonThrowing = syncNonThrowing
    asyncThrowing = syncThrowing
    syncThrowing = syncNonThrowing
    asyncThrowing = asyncNonThrowing

    // Error to remove 'async' or 'throws'
    syncNonThrowing = asyncNonThrowing // expected-error{{invalid conversion}}
    syncThrowing = asyncThrowing       // expected-error{{invalid conversion}}
    syncNonThrowing = syncThrowing     // expected-error{{invalid conversion}}
    asyncNonThrowing = syncThrowing    // expected-error{{invalid conversion}}
  }
}

// Overloading when there is conversion from sync to async.
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func bar(_ f: (Int) -> Int) -> Int {
  return f(2)
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func bar(_ f: (Int) async -> Int) async -> Int {
  return await f(2)
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func incrementSync(_ x: Int) -> Int {
  return x + 1
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func incrementAsync(_ x: Int) async -> Int {
  return x + 1
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
func testAsyncWithConversions() async {
  _ = bar(incrementSync)
  _ = bar { -$0 }
  _ = bar(incrementAsync)
  // expected-error@-1:7{{expression is 'async' but is not marked with 'await'}}{{7-7=await }}
  // expected-note@-2:7{{call is 'async'}}
}
