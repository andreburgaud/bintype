BUILD_DIR := "build"
DIST_DIR := "dist"
APP := "bintype"
APP_BIN := APP + ".exe"
VERSION := "1.2.0"

# Default recipe (this list)
default:
    @echo "App = {{APP}}"
    @echo "Executable = {{APP_BIN}}"
    @echo "OS: {{os()}}, OS Family: {{os_family()}}, architecture: {{arch()}}"
    @just --list

# Clean binaries
clean:
    -rm temp.lsp
    -rm *.zip
    -rm bintype.exe

# Check version
version:
    @echo {{VERSION}}

# Release build (to execute on Windows)
build: clean version
    newlisp build.lsp

# Create a release zip file (to execute on Linux)
dist:
    zip {{APP}}-{{VERSION}}-exe.zip {{APP_BIN}}

# Push and tag changes to github
push:
    git push
    git tag -a {{VERSION}} -m 'Version {{VERSION}}'
    git push origin --tags
