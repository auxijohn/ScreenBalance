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

subprojects {
    val setNamespace = { prj: Project ->
        val android = prj.extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    var defaultNamespace = prj.group?.toString()
                    if (defaultNamespace == null || defaultNamespace.isEmpty()) {
                        defaultNamespace = "com.example." + prj.name.replace("-", "_")
                    }
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(android, defaultNamespace)
                }
            } catch (e: Exception) {
                // ignore
            }
        }
    }
    if (state.executed) {
        setNamespace(this)
    } else {
        afterEvaluate {
            setNamespace(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
