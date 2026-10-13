ROBO SHOP — iOS App

Overview

ROBO SHOP is an iOS shopping application connected to the ROBO SHOP backend API.

The app should provide a clean, modern, responsive interface that matches the ROBO SHOP brand and supports the available backend features.

Important: Full-Screen Requirement

The ROBO SHOP app MUST display correctly in full screen on supported iPhones. It MUST NOT appear in half-screen mode, as a small centered window, or inside a restricted-height container.

The following requirements are mandatory:

* The app must use the full available iPhone screen.
* The main interface and background must extend across the available screen area.
* The layout must adapt to different supported iPhone screen sizes.
* Login, registration, products, orders, payment proof, and account screens must fit the available display.
* Safe areas must be handled correctly so that content does not overlap the status bar, Dynamic Island, or home indicator.
* The interface must not have an unintended blank area at the top or bottom.
* No fixed-height layout should force the app into a half-screen appearance.
* The app must be tested on an actual iPhone or an iPhone simulator to verify full-screen behavior.

Acceptance criterion: The app is not considered ready until the full-screen layout has been verified and the half-screen issue is resolved.

Features

* User login and registration
* Product listing
* Product search
* Order creation
* Order history
* Payment proof upload
* Secure token storage using iOS Keychain
* Backend API integration
* Responsive SwiftUI interface

Only features supported by the configured backend API can function correctly.

Technology

* Swift
* SwiftUI
* iOS 16.0 or later
* XcodeGen
* GitHub Actions
* HTTPS REST API

Project Structure

ROBO-SHOP/
├── README.md
├── project.yml
├── .github/
│   └── workflows/
│       └── build-ios.yml
└── ROBO SHOP/
    ├── ROBOShopApp.swift
    ├── Theme.swift
    ├── APIClient.swift
    ├── KeychainTokenStore.swift
    ├── RootView.swift
    └── Info.plist

Build Instructions

1. Upload all project files to the GitHub repository using the exact paths shown above.
2. Open the repository’s Actions tab.
3. Run the configured iOS build workflow, or push a commit to trigger it.
4. Check the workflow logs for build errors.
5. Download the generated artifact if the workflow succeeds.
6. Complete the required code signing and provisioning before installing the app on a physical iPhone.

Backend API

The application uses the configured ROBO SHOP public API.

The API base URL is defined in APIClient.swift. Keep the URL consistent with the actual backend deployment and verify that the required endpoints are available.

Release Checklist

* [ ]	GitHub Actions build completes successfully.
* [ ]	The app launches without crashing.
* [ ]	The app displays in full screen on supported iPhones.
* [ ]	No half-screen or unintended blank-space layout appears.
* [ ]	Login and registration are tested against the backend.
* [ ]	Products and orders load correctly.
* [ ]	Order creation and payment proof upload are tested.
* [ ]	Code signing and installation are verified before release.

Important Note

The full-screen requirement is mandatory, but this README does not itself change the app layout. The SwiftUI implementation and iOS project configuration must satisfy the requirement, and the final build must be tested before release.