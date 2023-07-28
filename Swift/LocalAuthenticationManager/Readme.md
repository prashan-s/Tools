## LocalAuthenticationManager :closed_lock_with_key:

`LocalAuthenticationManager` is a utility class that simplifies the use of Local Authentication in your iOS apps. It provides an easy-to-use interface for handling biometric (Face ID or Touch ID) authentication.

### Features :sparkles:

- **TypeAlias**: Includes a `LAMResultCompletion` typealias for completion handlers dealing with local authentication results.
- **Enums**: Includes a `LAMResult` enum for success and failure cases, and a `Mode` enum for specifying the authentication mode.
- **Biometric and Password Authentication**: Supports both biometric and password authentication based on the specified mode.
- **Error Handling**: Provides comprehensive error handling for various local authentication errors.

### Usage :computer:

```swift
let lam = LocalAuthenticationManager()
lam.evaluate(localizedReason: "Access requires authentication") { result in
    switch result {
    case .Success:
        print("Authentication Successful")
    case .Faliure(let error):
        print("Authentication Failed with error: \(error)")
    }
}
