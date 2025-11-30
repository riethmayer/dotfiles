# Java and Maven Configuration
# Maven installation and configuration

# Check for Maven in common locations
MAVEN_PATHS=(
    "${HOME}/bin/apache-maven-3.9.6"
    "${HOME}/bin/apache-maven"
    "${XDG_DATA_HOME}/maven"
    "/opt/homebrew/opt/maven"
    "/usr/local/opt/maven"
)

# Find and configure Maven
for maven_path in "${MAVEN_PATHS[@]}"; do
    if [ -d "${maven_path}" ] && [ -f "${maven_path}/bin/mvn" ]; then
        export M2_HOME="${maven_path}"
        export PATH="${M2_HOME}/bin:$PATH"
        break
    fi
done
