# Contributing to TrayOff

Thank you for your interest in contributing to TrayOff! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/TrayOff.git`
3. Open `TrayOff.xcodeproj` in Xcode 15.0+
4. Build and run on iOS 16.0+ simulator or device

## Code Style

### Swift Guidelines

Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

### Documentation

All public types, methods, and properties must have documentation comments:

```swift
/// A recorded session representing a period when the retainer was off.
///
/// Sessions are persisted using SwiftData and used to calculate daily usage
/// statistics, streaks, and goal compliance.
@Model
final class Session {
    /// Unique identifier for the session.
    var id: UUID
    
    /// Creates a new session with the given start and end times.
    /// - Parameters:
    ///   - start: When the retainer was removed.
    ///   - end: When the retainer was put back on.
    init(start: Date, end: Date) { ... }
}
```

### MARK Comments

Use MARK comments to organize code sections:

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
```

### File Headers

All Swift files include a standard header:

```swift
//
//  FileName.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//
```

## Submitting Changes

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes following the code style guidelines
3. Test your changes thoroughly
4. Commit with clear, descriptive messages
5. Push to your fork and open a Pull Request

## Reporting Issues

When reporting issues, please include:

- iOS version
- Device or simulator used
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
