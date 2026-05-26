# Dragonpass Hybrid SDK for Android

Dragonpass Hybrid SDK for Android lets a host app launch and interact with Dragonpass DPApps.

This repository distributes the Android DPSDK through JitPack. It does not include SDK source code, credentials, or demo projects.

## Requirements

- Android 5.0 (API level 21) or later
- Android Gradle Plugin / Gradle setup with JitPack support
- A registered `clientId`
- A DPApp `appId`
- A host-app auth-code flow

To request or confirm your `clientId`, DPApp `appId`, and auth-code setup, contact the Dragonpass DPSDK team through [Contact Us](https://github.com/bigBandFE/dpsdk-contact/).

## Installation

For manual installation with Gradle / JitPack:

Add JitPack to dependency resolution:

```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}
```

Add the dependency to your app module:

```kotlin
dependencies {
    implementation("com.github.bigBandFE:dpsdk-android:2.0.0")
}
```

If your host app still depends on AndroidX migration compatibility, add this to `gradle.properties`:

```properties
android.enableJetifier=true
```

You can also use the AI-assisted integration skill after reviewing the manual installation steps:

```bash
hermes skills install --category devops --yes \
  "https://raw.githubusercontent.com/bigBandFE/dpsdk-ai-skill/main/SKILL.md"
```

## Basic Usage

Initialize DPSDK from the host `Application`:

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        DPSDK.init(this).setDPSdkConfig(
            DPSDKConfig.Builder()
                .setClientId("<client_id>")
                .setIsLog(BuildConfig.DEBUG)
                .setDebug(BuildConfig.DEBUG)
                .setLanguage("en-US")
                .setEnv(DPSDK.Env.UAT)
                .build()
        )
    }
}
```

Register the `Application` class in `AndroidManifest.xml`:

```xml
<application
    android:name=".MyApplication"
    ...>
```

After your host app obtains a non-empty auth code from its backend/auth flow, pass it to the SDK:

```kotlin
DPSDK.setAuthCode("<auth_code>")
```

Refresh remote DPApp configuration before showing DPApp entry points:

```kotlin
DPSDK.updateConfig(onSuccess = {
    DPSDK.getDPApps(onSuccess = { apps ->
        // Enable entry points for available app IDs.
    })
}, onError = { code, msg ->
    // Show a host-app controlled failure state.
})
```

Open a DPApp from a valid Activity context:

```kotlin
val appId = "<app_id>"
DPSDK.getDPApp(appId).open(this)
```

## Custom Events

Register custom event handlers before opening the DPApp when the miniapp needs host capabilities:

```kotlin
val appId = "<app_id>"

DPSDK.getDPApp(appId)
    .setCustomEventListener { activity, data, event, callback ->
        when (event.eventType) {
            "requestLocationPermission" -> {
                // Request permission in the host app, then call callback.
            }
        }
    }
    .open(this)
```

## Troubleshooting

- Dependency resolution failure: confirm JitPack is configured and the dependency version exists.
- Startup failure: confirm `clientId` is registered for your host app.
- Blank or unavailable DPApp: confirm the DPApp `appId` and auth-code flow with the Dragonpass DPSDK team.
- Auth errors: ensure the host app obtains a fresh non-empty auth code before opening DPApps.
- WebView or JSBridge callback issues: register custom event handlers before opening the DPApp.

For setup support, open a request through [Contact Us](https://github.com/bigBandFE/dpsdk-contact/).
