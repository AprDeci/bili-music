allprojects {
    buildscript {
        // 配置构建脚本自身的仓库（用于下载Gradle插件等）
        repositories {
            maven { url = uri("https://maven.aliyun.com/repository/public/") }
            maven { url = uri("https://maven.aliyun.com/repository/google/") }
            maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin/") }
            mavenCentral() // 保留中央仓库作为备用
        }
    }

    // 配置项目本身的依赖仓库
    repositories {
        // 使用阿里云代理的公共仓库
        maven { url = uri("https://maven.aliyun.com/repository/public/") }
        // 使用阿里云代理的Google仓库（Android开发必备）
        maven { url = uri("https://maven.aliyun.com/repository/google/") }
        // 使用阿里云代理的Gradle插件仓库
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin/") }
        // 保留Maven中央仓库，当镜像源没有所需依赖时可回退（但通常阿里云很全）
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
