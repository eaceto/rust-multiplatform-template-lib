#!/usr/bin/env bash
#
# run_me_first.sh - Template Initialization Script
#
# This script helps you customize the rust-multiplatform-template-lib
# for your own project by renaming all identifiers consistently.
#
# It will:
# 1. Collect all necessary names from you
# 2. Validate the names
# 3. Update all files in the project
# 4. Update demo apps to use the new names
# 5. Keep existing git history
#
# Usage: ./scripts/run_me_first.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Validation functions
validate_rust_crate_name() {
    local name="$1"

    # Check if empty
    if [[ -z "$name" ]]; then
        return 1
    fi

    # Must be lowercase with hyphens only
    if ! [[ "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
        print_error "Rust crate name must be lowercase with hyphens only (e.g., my-awesome-lib)"
        return 1
    fi

    # Cannot start or end with hyphen
    if [[ "$name" =~ ^- ]] || [[ "$name" =~ -$ ]]; then
        print_error "Rust crate name cannot start or end with a hyphen"
        return 1
    fi

    # Check against Rust reserved keywords
    local reserved_words=("abstract" "as" "async" "await" "become" "box" "break" "const" "continue" "crate" "do" "dyn" "else" "enum" "extern" "false" "final" "fn" "for" "if" "impl" "in" "let" "loop" "macro" "match" "mod" "move" "mut" "override" "priv" "pub" "ref" "return" "self" "static" "struct" "super" "trait" "true" "try" "type" "typeof" "unsafe" "unsized" "use" "virtual" "where" "while" "yield")

    for word in "${reserved_words[@]}"; do
        if [[ "$name" == "$word" ]]; then
            print_error "Cannot use Rust reserved keyword: $word"
            return 1
        fi
    done

    return 0
}

validate_swift_module_name() {
    local name="$1"

    # Check if empty
    if [[ -z "$name" ]]; then
        return 1
    fi

    # Must be PascalCase (start with uppercase, alphanumeric only)
    if ! [[ "$name" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
        print_error "Swift module name must be PascalCase (e.g., MyAwesomeLib)"
        return 1
    fi

    # Check length (Swift has practical limits)
    if [[ ${#name} -gt 50 ]]; then
        print_error "Swift module name too long (max 50 characters)"
        return 1
    fi

    return 0
}

validate_java_package() {
    local package="$1"

    # Check if empty
    if [[ -z "$package" ]]; then
        return 1
    fi

    # Must be lowercase with dots separating segments
    if ! [[ "$package" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$ ]]; then
        print_error "Java package must be lowercase with dots (e.g., com.example.mylib)"
        return 1
    fi

    # Must have at least 2 segments
    if [[ $(echo "$package" | tr -cd '.' | wc -c) -lt 1 ]]; then
        print_error "Java package must have at least 2 segments (e.g., com.example)"
        return 1
    fi

    # Check against Java reserved keywords in each segment
    local reserved_words=("abstract" "assert" "boolean" "break" "byte" "case" "catch" "char" "class" "const" "continue" "default" "do" "double" "else" "enum" "extends" "final" "finally" "float" "for" "goto" "if" "implements" "import" "instanceof" "int" "interface" "long" "native" "new" "package" "private" "protected" "public" "return" "short" "static" "strictfp" "super" "switch" "synchronized" "this" "throw" "throws" "transient" "try" "void" "volatile" "while")

    IFS='.' read -ra SEGMENTS <<< "$package"
    for segment in "${SEGMENTS[@]}"; do
        for word in "${reserved_words[@]}"; do
            if [[ "$segment" == "$word" ]]; then
                print_error "Cannot use Java reserved keyword in package: $word"
                return 1
            fi
        done
    done

    return 0
}

# Conversion functions
kebab_to_snake() {
    echo "$1" | tr '-' '_'
}

kebab_to_pascal() {
    echo "$1" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' | sed 's/ //g'
}

# Main script
clear
print_header "🦀 Rust Multiplatform Template - Initialization Script"

echo "This script will help you customize the template for your project."
echo "It will rename all identifiers consistently across all files."
echo ""
print_warning "IMPORTANT: Make sure you have committed any changes before running this!"
echo ""
read -p "Press Enter to continue or Ctrl+C to abort..."

# Navigate to project root
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"

print_info "Project root: $PROJECT_ROOT"
echo ""

# ============================================================================
# Step 1: Collect Rust crate name
# ============================================================================
print_header "Step 1: Rust Crate Name"

echo "Enter your Rust crate name (kebab-case):"
echo "  - Use lowercase letters, numbers, and hyphens only"
echo "  - Example: my-awesome-lib, crypto-toolkit, data-processor"
echo ""

while true; do
    read -p "Rust crate name: " RUST_CRATE_NAME

    if validate_rust_crate_name "$RUST_CRATE_NAME"; then
        RUST_LIB_NAME=$(kebab_to_snake "$RUST_CRATE_NAME")
        print_success "Valid crate name: $RUST_CRATE_NAME (lib: $RUST_LIB_NAME)"
        break
    fi
done

# ============================================================================
# Step 2: Collect Swift module name
# ============================================================================
print_header "Step 2: Swift Module Name"

SUGGESTED_SWIFT=$(kebab_to_pascal "$RUST_CRATE_NAME")

echo "Enter your Swift module/framework name (PascalCase):"
echo "  - Use PascalCase (first letter uppercase)"
echo "  - Example: MyAwesomeLib, CryptoToolkit, DataProcessor"
echo ""
echo "Suggested based on crate name: $SUGGESTED_SWIFT"
echo ""

while true; do
    read -p "Swift module name [$SUGGESTED_SWIFT]: " SWIFT_MODULE_NAME

    # Use suggested if empty
    if [[ -z "$SWIFT_MODULE_NAME" ]]; then
        SWIFT_MODULE_NAME="$SUGGESTED_SWIFT"
    fi

    if validate_swift_module_name "$SWIFT_MODULE_NAME"; then
        print_success "Valid Swift module name: $SWIFT_MODULE_NAME"
        break
    fi
done

# ============================================================================
# Step 3: Collect Java/Kotlin package name
# ============================================================================
print_header "Step 3: Java/Kotlin Package Name"

echo "Enter your Java/Kotlin package name (reverse domain notation):"
echo "  - Use lowercase with dots separating segments"
echo "  - Must have at least 2 segments"
echo "  - Example: com.example.mylib, io.github.username.mylib"
echo ""

while true; do
    read -p "Java package name: " JAVA_PACKAGE

    if validate_java_package "$JAVA_PACKAGE"; then
        # Extract group and artifact
        MAVEN_GROUP=$(echo "$JAVA_PACKAGE" | rev | cut -d'.' -f2- | rev)
        MAVEN_ARTIFACT=$(echo "$JAVA_PACKAGE" | rev | cut -d'.' -f1 | rev)

        print_success "Valid package: $JAVA_PACKAGE"
        print_info "Maven group: $MAVEN_GROUP"
        print_info "Maven artifact: $MAVEN_ARTIFACT"
        break
    fi
done

# ============================================================================
# Step 4: Summary and confirmation
# ============================================================================
print_header "Summary"

echo "The following changes will be made:"
echo ""
echo "  Rust:"
echo "    - Crate name:     rust-multiplatform-template-lib → $RUST_CRATE_NAME"
echo "    - Lib name:       rust_multiplatform_template_lib → $RUST_LIB_NAME"
echo "    - XCFramework:    librust_multiplatform_template_lib → lib${RUST_LIB_NAME}"
echo ""
echo "  Swift:"
echo "    - Module name:    Template → $SWIFT_MODULE_NAME"
echo "    - UDL namespace:  Template → $SWIFT_MODULE_NAME"
echo ""
echo "  Kotlin/Java:"
echo "    - Package:        com.template → $MAVEN_GROUP"
echo "    - Module name:    template → $MAVEN_ARTIFACT"
echo "    - Artifact ID:    template → $MAVEN_ARTIFACT"
echo ""
echo "  Demo Apps:"
echo "    - Will be updated to use new package names"
echo ""

read -p "Proceed with these changes? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    print_error "Aborted by user"
    exit 1
fi

# ============================================================================
# Step 5: Perform replacements
# ============================================================================
print_header "Applying Changes"

print_info "This may take a moment..."
echo ""

# Counter for modified files
MODIFIED_FILES=0

# Function to replace in file
replace_in_file() {
    local file="$1"
    local search="$2"
    local replace="$3"

    if [[ -f "$file" ]] && grep -q "$search" "$file" 2>/dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|$search|$replace|g" "$file"
        else
            sed -i "s|$search|$replace|g" "$file"
        fi
        ((MODIFIED_FILES++))
        return 0
    fi
    return 1
}

# Rust crate name replacements
print_info "Updating Rust crate names..."
replace_in_file "Cargo.toml" "name = \"rust-multiplatform-template-lib\"" "name = \"$RUST_CRATE_NAME\""
replace_in_file "Cargo.toml" "name = \"rust_multiplatform_template_lib\"" "name = \"$RUST_LIB_NAME\""

# Update lib.rs
if replace_in_file "src/lib.rs" "rust_multiplatform_template_lib" "$RUST_LIB_NAME"; then
    print_success "Updated src/lib.rs"
fi

# UDL namespace
print_info "Updating UniFFI namespace..."
replace_in_file "src/template.udl" "namespace Template" "namespace $SWIFT_MODULE_NAME"

# Rename UDL file
if [[ -f "src/template.udl" ]]; then
    NEW_UDL_NAME=$(echo "$SWIFT_MODULE_NAME" | awk '{print tolower($0)}')
    mv "src/template.udl" "src/${NEW_UDL_NAME}.udl"
    print_success "Renamed template.udl → ${NEW_UDL_NAME}.udl"

    # Update reference in lib.rs
    replace_in_file "src/lib.rs" 'uniffi::include_scaffolding!("template")' "uniffi::include_scaffolding!(\"${NEW_UDL_NAME}\")"
fi

# Swift Package
print_info "Updating Swift package..."
replace_in_file "platforms/apple/Package.swift" "name: \"Template\"" "name: \"$SWIFT_MODULE_NAME\""
replace_in_file "platforms/apple/Package.swift" "name: \"Template\"" "name: \"$SWIFT_MODULE_NAME\""
replace_in_file "platforms/apple/Package.swift" "\"Template\"" "\"$SWIFT_MODULE_NAME\""
replace_in_file "platforms/apple/Package.swift" "name: \"TemplateFFI\"" "name: \"${SWIFT_MODULE_NAME}FFI\""
replace_in_file "platforms/apple/Package.swift" "\"TemplateFFI\"" "\"${SWIFT_MODULE_NAME}FFI\""
replace_in_file "platforms/apple/Package.swift" "librust_multiplatform_template_lib.xcframework" "lib${RUST_LIB_NAME}.xcframework"
replace_in_file "platforms/apple/Package.swift" "name: \"TemplateTests\"" "name: \"${SWIFT_MODULE_NAME}Tests\""
replace_in_file "platforms/apple/Package.swift" "Tests/TemplateTests" "Tests/${SWIFT_MODULE_NAME}Tests"

# Rename Swift directories
if [[ -d "platforms/apple/Sources/Template" ]]; then
    mv "platforms/apple/Sources/Template" "platforms/apple/Sources/$SWIFT_MODULE_NAME"
    print_success "Renamed Sources/Template → Sources/$SWIFT_MODULE_NAME"
fi

if [[ -d "platforms/apple/Tests/TemplateTests" ]]; then
    mv "platforms/apple/Tests/TemplateTests" "platforms/apple/Tests/${SWIFT_MODULE_NAME}Tests"
    print_success "Renamed Tests/TemplateTests → Tests/${SWIFT_MODULE_NAME}Tests"
fi

# Update Swift source files
find platforms/apple -name "*.swift" -type f -exec sed -i.bak "s/import Template/import $SWIFT_MODULE_NAME/g" {} \;
find platforms/apple -name "*.swift.bak" -type f -delete

# Kotlin/Gradle
print_info "Updating Kotlin/Gradle configuration..."
replace_in_file "platforms/kotlin/build.gradle.kts" "group = \"com.template\"" "group = \"$MAVEN_GROUP\""
replace_in_file "platforms/kotlin/build.gradle.kts" "namespace = \"com.template\"" "namespace = \"$MAVEN_GROUP\""
replace_in_file "platforms/kotlin/settings.gradle.kts" "rootProject.name = \"template\"" "rootProject.name = \"$MAVEN_ARTIFACT\""

# Update Kotlin package names
print_info "Updating Kotlin package declarations..."
find platforms/kotlin/src -name "*.kt" -type f -exec sed -i.bak "s/package com\.template/package $MAVEN_GROUP/g" {} \;
find platforms/kotlin/src -name "*.kt" -type f -exec sed -i.bak "s/package com\.rust\.template/package ${MAVEN_GROUP}.rust/g" {} \;
find platforms/kotlin/src -name "*.kt" -type f -exec sed -i.bak "s/import com\.template\./import ${MAVEN_GROUP}./g" {} \;
find platforms/kotlin/src -name "*.kt" -type f -exec sed -i.bak "s/import com\.rust\.template/import ${MAVEN_GROUP}.rust/g" {} \;
find platforms/kotlin/src -name "*.kt.bak" -type f -delete

# Update demo apps
print_info "Updating demo applications..."

# Android app
if [[ -f "apps/android/settings.gradle.kts" ]]; then
    replace_in_file "apps/android/settings.gradle.kts" "com.template:template" "$MAVEN_GROUP:$MAVEN_ARTIFACT"
fi
if [[ -f "apps/android/app/build.gradle.kts" ]]; then
    replace_in_file "apps/android/app/build.gradle.kts" "implementation(\"com.template:template" "implementation(\"$MAVEN_GROUP:$MAVEN_ARTIFACT"
fi

# Desktop app
if [[ -f "apps/desktop/settings.gradle.kts" ]]; then
    replace_in_file "apps/desktop/settings.gradle.kts" "com.template:template" "$MAVEN_GROUP:$MAVEN_ARTIFACT"
fi
if [[ -f "apps/desktop/build.gradle.kts" ]]; then
    replace_in_file "apps/desktop/build.gradle.kts" "implementation(\"com.template:template" "implementation(\"$MAVEN_GROUP:$MAVEN_ARTIFACT"
fi

# Apple demo app
find apps/apple -name "*.swift" -type f -exec sed -i.bak "s/import Template/import $SWIFT_MODULE_NAME/g" {} \;
find apps/apple -name "*.swift.bak" -type f -delete

# Update documentation
print_info "Updating documentation..."
find . -name "*.md" -type f ! -path "*/target/*" ! -path "*/.git/*" -exec sed -i.bak "s/rust-multiplatform-template-lib/$RUST_CRATE_NAME/g" {} \;
find . -name "*.md" -type f ! -path "*/target/*" ! -path "*/.git/*" -exec sed -i.bak "s/rust_multiplatform_template_lib/$RUST_LIB_NAME/g" {} \;
find . -name "*.md.bak" -type f -delete

print_success "Updated $MODIFIED_FILES files"

# ============================================================================
# Step 6: Clean up build artifacts
# ============================================================================
print_header "Cleaning Build Artifacts"

print_info "Removing old build artifacts..."

# Clean Rust
if [[ -d "target" ]]; then
    rm -rf target
    print_success "Cleaned Rust target/"
fi

# Clean Swift
if [[ -d "platforms/apple/.build" ]]; then
    rm -rf platforms/apple/.build
    print_success "Cleaned Swift .build/"
fi

if [[ -d "platforms/apple/xcframework" ]]; then
    rm -rf platforms/apple/xcframework
    print_success "Cleaned xcframework/"
fi

# Clean Kotlin
if [[ -d "platforms/kotlin/build" ]]; then
    rm -rf platforms/kotlin/build
    print_success "Cleaned Kotlin build/"
fi

if [[ -d "platforms/kotlin/.gradle" ]]; then
    rm -rf platforms/kotlin/.gradle
    print_success "Cleaned Kotlin .gradle/"
fi

# Clean apps
find apps -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
find apps -name ".gradle" -type d -exec rm -rf {} + 2>/dev/null || true
print_success "Cleaned demo app builds"

# ============================================================================
# Step 7: Summary
# ============================================================================
print_header "✨ Setup Complete!"

echo "Your project has been successfully configured!"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review the changes:"
echo "     ${CYAN}git status${NC}"
echo "     ${CYAN}git diff${NC}"
echo ""
echo "  2. Test the build:"
echo "     ${CYAN}cargo build${NC}"
echo "     ${CYAN}cargo test${NC}"
echo ""
echo "  3. Build for all platforms:"
echo "     ${CYAN}./scripts/build-all.sh${NC}"
echo ""
echo "  4. Commit the changes:"
echo "     ${CYAN}git add .${NC}"
echo "     ${CYAN}git commit -m \"Initialize project: $RUST_CRATE_NAME\"${NC}"
echo ""

print_success "Done! Happy coding! 🚀"
echo ""
