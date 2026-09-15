allprojects {
    repositories {
        google()
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

// Workaround: some older/unmaintained plugins (e.g. `telephony`) predate the
// Android Gradle Plugin's namespace requirement and never declared one in
// their own build.gradle. Inject a namespace for any library module that's
// missing it, so the build doesn't fail on their behalf.
// NOTE: uses pluginManager.withPlugin (not afterEvaluate) because Flutter's
// plugin loader can evaluate native plugin projects as a side effect of
// evaluating :app, which happens before our config would otherwise run.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = "com.finadvisor.plugins.${project.name.replace("-", "_")}"
            }
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    // Same story: force a consistent Kotlin JVM target across every module
    // (including old native plugins) so their Kotlin/Java compile tasks
    // don't disagree with each other or with the app's own JVM 17 target.
    pluginManager.withPlugin("org.jetbrains.kotlin.android") {
        extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension> {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
