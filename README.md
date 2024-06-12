# Integrator

### Quick Introduction

**Integrator** Framework was developed to integrate basic needed functionality into your apps as quick as possible, without extra hussle and extra stuff your project doesn't need

Adding integrator in your project can currently be done only using **SPM** (*Swift Package Manager*). 

---
### Adding the Framework

Integrating the framework as fast as possible is a key feature of this Framework, making it a perfect companion for your projects.
Let's start by adding the **SPM Dependency** into our project

Start by going to the core target of your project, and navigating to **Package Dependencies**:


In this window, press the "**+**" button to add a new dependency. Use URL of the Integrator Framework Git repository to add it to your project. Add the needed version of the repository, select the project you want to add the dependency to and click the "**Add package**" at the bottom of the window.


As soon as the dependency downloads, add the **Integrator**, **IntegratorClient**, **IntegratorDefaults**, **Analytical** and **Acquisitor** libraries to the needed target, and press "**Add package**":


At this point, the framework will start downloading all the needed dependencies such as **Firebase** and **AppsFlyer**.

#### Congratulations! You've successfully added the Integrator Framework to your project!

---
### Integrating the codebase into your project

Let's now continue by adding the basic integration to your project.
For this - you'll need to add an **AppDelegate** to your project if the project is written in SwiftUI (_I believe in you to know how to do it, so we'll skip directly to the integration_)
As soon as you've added the AppDelegate to your project, let's quickly add a couple of functions inside your AppDelegate class:

``` swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
) -> Bool {
    Integrator.startIntegration(
        with: application,
        options: launchOptions,
        parent: AnyView(Text("Hello cruel world"))
    )
    
    return true
}

func applicationDidBecomeActive(
    _ application: UIApplication
) {
    Integrator.applicationDidBecomeActive(application)
}

func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    Integrator.application(
        app,
        open: url,
        options: options
    )
    
    return true
}

func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    Integrator.application(
        application,
        continue: userActivity,
        restorationHandler: restorationHandler
    )
    
    return true
}
```

> _Don't forget to import Integrator for this functions to work_

> _The **parent** is the main view of the app that you want to present after the integration is done. **THIS IS NOT THE SPLASH SCREEN ⚠️**_* 

After you've added the basic code to your AppDelegate, it's time to add the configurations for the dependencies.
Configurations, like Framework Keys - are kept in the **project's Info.plist**
A basic **Info.plist** should look like this:

``` swift
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>RECEIPT_KEYS</key>
	<string>shared_secret</string>
	<key>APP_ID</key>
	<string>1678338182</string>
	<key>APPSFLYER_KEY</key>
	<string>L7MkFhoZqUqfzKYXNxoHwe</string>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>deeplink</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>cleanerfydeep</string>
			</array>
		</dict>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>deeplinkSecondary</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>cleanerfydeepsec</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```



> _In order for Firebase to function properly, don't forget to add the **GoogleService-Info.plist** inside the project_

This should be it for the basic integrator. Easy - right? :smile:

---
### Mentions

The Integrator framework has 5 libraries. The main one you'll use is the **Integrator** library itself.

If you need to add purchasing capabilites to your core app - use the **Acquisitor** library:
``` swift
import Acquisitor

Acquisitor.shared.retrieve(
  products: [String],
  completion: (Bool) -> Void
)
    
Acquisitor.shared.restoreAcquisition(
  for: String,
  completion: (Acquisitor.RestoreResult) -> Void
)
    
Acquisitor.shared.acquire(
  product: String,
  completion: (PurchaseDetails?) -> Void
)
```

If you need to send some more analytical data to Firebase and/or Appsflyer - use the **Analytical** library:

> _Currently - the Analytical library only gives you access to sending purchase information about a product purchase. This is also done automatically in the Acquisitor library. If more functionality is needed - contact the original creator of the Framework_

``` swift
AnalyticalClient().trackEvents(
  productId: String,
  productPrice: Double,
  transactionId: String,
  transactionDate: String,
  locale: String
)
```

**IntegratorClient** is a basic API Client library that allows you to send _GET_ and _POST_ requests, and expect a _Codable_ object response:

``` swift
IntegratorClient.shared.get(
  url: URL,
  _ type: (Decodable & Encodable).Protocol,
  completion: ((Decodable & Encodable)?) -> Void>
)
    
IntegratorClient.shared.post(
  url: URL,
  parameters: [String : Any],
  _ type: (Decodable & Encodable).Protocol,
  completion: ((Decodable & Encodable)?) -> Void>
)
```






