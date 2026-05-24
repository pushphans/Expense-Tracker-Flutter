import com.android.build.gradle.LibraryExtension

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

    plugins.withId("com.android.library") {
        val manifestFile = project.file("src/main/AndroidManifest.xml")
        val manifestText = if (manifestFile.exists()) manifestFile.readText() else null
        val manifestPackage = manifestText
            ?.let { Regex("package=\"([^\"]+)\"").find(it)?.groupValues?.get(1) }

        if (manifestText != null && manifestPackage != null) {
            val updatedManifest = manifestText.replace(
                Regex("\\s+package=\"[^\"]+\""),
                "",
            )
            if (updatedManifest != manifestText) {
                manifestFile.writeText(updatedManifest)
            }
        }

        extensions.configure<LibraryExtension> {
            if (namespace == null) {
                namespace = manifestPackage ?: "com.example.${project.name.replace('-', '_')}"
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
