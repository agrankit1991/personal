# ===============================
# Development Server Functions (Bash)
# ===============================
# Automatically detect and start development servers

# -----------------------------------------------
# Private Helper Functions
# -----------------------------------------------

# Check if Spring Boot project
_is_spring_boot() {
    # Check if build files exist
    if [[ -f "build.gradle" || -f "build.gradle.kts" || -f "pom.xml" ]]; then
        # Check for spring-boot dependency recursively (limit depth to speed it up)
        # Note: 'grep -r' can be slow in large dirs, so we limit to build files if possible
        if grep -q "spring-boot" build.gradle 2>/dev/null || \
           grep -q "spring-boot" build.gradle.kts 2>/dev/null || \
           grep -q "spring-boot" pom.xml 2>/dev/null; then
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
        # Ensure executable permission
        chmod +x ./gradlew 2>/dev/null
        ./gradlew bootRun
    else
        gradle bootRun
    fi
}

# Start Spring Boot with Maven
_start_maven_boot() {
    echo "🚀 Starting Spring Boot (Maven)..."
    if [[ -f "mvnw" ]]; then
        # Ensure executable permission
        chmod +x ./mvnw 2>/dev/null
        ./mvnw spring-boot:run
    else
        mvn spring-boot:run
    fi
}

# Start Next.js development server
_start_nextjs() {
    echo "🚀 Starting Next.js dev server..."
    if [[ -f "yarn.lock" ]]; then
        yarn dev
    elif [[ -f "pnpm-lock.yaml" ]]; then
        pnpm dev
    elif [[ -f "bun.lockb" ]]; then
        bun dev
    else
        npm run dev
    fi
}

# -----------------------------------------------
# Public Functions
# -----------------------------------------------

# Auto-detect and start development server
function start-server() {
    echo "🔍 Detecting project type..."
    echo ""

    # Check for Spring Boot with Gradle
    if _is_gradle && _is_spring_boot; then
        echo "✅ Detected: Spring Boot (Gradle)"
        _start_gradle_boot
        return $?
    fi

    # Check for Spring Boot with Maven
    if _is_maven && _is_spring_boot; then
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
    echo "👉 Make sure you're in the project root directory"
    return 1
}

# Add alias for convenience
alias ss='start-server'
