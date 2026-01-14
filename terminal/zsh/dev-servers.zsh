# ===============================
# Development Server Functions
# ===============================
# Automatically detect and start development servers

# -----------------------------------------------
# Private Helper Functions
# -----------------------------------------------

# Check if Spring Boot project
_is_spring_boot() {
    if [[ -f "build.gradle" || -f "build.gradle.kts" || -f "pom.xml" ]]; then
        if grep -r "spring-boot" . 2>/dev/null | head -1 | grep -q "spring-boot"; then
            return 0
        fi
    fi
    return 1
}

# Check if Gradle project
_is_gradle() {
    [[ -f "build.gradle" || -f "build.gradle.kts" || -f "gradlew" ]]
}

# Check if Maven project
_is_maven() {
    [[ -f "pom.xml" || -f "mvnw" ]]
}

# Check if Next.js project
_is_nextjs() {
    [[ -f "package.json" ]] && grep -q "next" package.json
}

# -----------------------------------------------
# Private Implementation Functions
# -----------------------------------------------

# Start Spring Boot with Gradle
_start_gradle_boot() {
    echo "🚀 Starting Spring Boot (Gradle)..."
    if [[ -f "gradlew" ]]; then
        ./gradlew bootRun
    else
        gradle bootRun
    fi
}

# Start Spring Boot with Maven
_start_maven_boot() {
    echo "🚀 Starting Spring Boot (Maven)..."
    if [[ -f "mvnw" ]]; then
        ./mvnw spring-boot:run
    else
        mvn spring-boot:run
    fi
}

# Start Next.js development server
_start_nextjs() {
    echo "🚀 Starting Next.js dev server..."
    npm run dev
}

# -----------------------------------------------
# Public Functions
# -----------------------------------------------

# Auto-detect and start development server
function start-server() {
    echo "🔍 Detecting project type..."
    echo ""

    # Check for Spring Boot with Gradle
    if _is_spring_boot && _is_gradle; then
        echo "✅ Detected: Spring Boot (Gradle)"
        _start_gradle_boot
        return $?
    fi

    # Check for Spring Boot with Maven
    if _is_spring_boot && _is_maven; then
        echo "✅ Detected: Spring Boot (Maven)"
        _start_maven_boot
        return $?
    fi

    # Check for Next.js
    if _is_nextjs; then
        echo "✅ Detected: Next.js"
        _start_nextjs
        return $?
    fi

    # No supported project found
    echo "❌ Could not detect a supported project type"
    echo ""
    echo "💡 Supported:"
    echo "   • Spring Boot (Gradle) - requires build.gradle/build.gradle.kts"
    echo "   • Spring Boot (Maven)  - requires pom.xml"
    echo "   • Next.js              - requires package.json with 'next' dependency"
    echo ""
    echo "� Make sure you're in the project root directory"
    return 1
}

alias ss='start-server'
