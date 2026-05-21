# dpsdk-android

这是一个用于分发闭源 `dpsdk` Android AAR 的 `JitPack wrapper` 仓库。

## 工作原理

1. 在公司内部源码仓库中构建真实的 SDK AAR。
2. 将 `dpsdk-<version>.aar` 上传到当前仓库的 GitHub Release 附件中。
3. 创建对应的 Git Tag，格式为 `v<version>`。
4. JitPack 在构建时从 GitHub Release 下载该 AAR，并重新发布为 Maven 制品。

## 发布约定

- Git Tag：`v2.0.0`
- GitHub Release 附件：`dpsdk-2.0.0.aar`
- 依赖版本号：`v2.0.0`

## JitPack 依赖坐标

```gradle
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

dependencies {
    implementation("com.github.bigBandFE:dpsdk:v2.0.0")
}
```

## 本地校验

当你已经上传了匹配版本的 GitHub Release 附件后，可以在本地执行：

```bash
./gradlew printReleaseInfo publishToMavenLocal -PSDK_VERSION=2.0.0
```

发布后的产物会安装到本地 Maven 仓库目录：

```text
~/.m2/repository/com/github/bigBandFE/dpsdk/2.0.0/
```

## 发版步骤

1. 在内部源码仓库中构建闭源 SDK，并导出最终 AAR。
2. 进入当前仓库后执行发布脚本：

```bash
./scripts/release_aar.sh 2.0.0 /absolute/path/to/dpsdk-2.0.0.aar
```

3. 打开 JitPack 页面，触发 `v2.0.0` 的首次构建：

```text
https://jitpack.io/#bigBandFE/dpsdk-android/v2.0.0
```

4. 在业务工程中验证依赖是否可以正常解析：

```gradle
implementation("com.github.bigBandFE:dpsdk:v2.0.0")
```

## 发布脚本说明

- 该脚本依赖 GitHub CLI，如未安装可执行：`brew install gh`
- 首次使用前需要登录：`gh auth login`
- 脚本会自动创建或更新 GitHub Release `v<version>`
- 上传后的附件名称会被统一规范成 `dpsdk-<version>.aar`
- 如需覆盖默认仓库地址，可以这样执行：

```bash
GITHUB_REPO=bigBandFE/dpsdk-android ./scripts/release_aar.sh 2.0.0 /path/to/file.aar
```

## 注意事项

- 不要将 SDK 源码提交到当前仓库。
- 如果 AAR 依赖第三方库，需要同步维护 `build.gradle` 中的 `runtimeDeps`，否则接入方可能出现缺类问题。
- 默认的 GitHub Release 附件下载地址格式为：

```text
https://github.com/bigBandFE/dpsdk-android/releases/download/v<version>/dpsdk-<version>.aar
```
