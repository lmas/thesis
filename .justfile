
PAPER := "thesis"
COVER := ".cover"
TARGETS := "$(go list ./... | grep -v /tmp)"

# Show available recipes by default
default:
    @just --list

# Recompile the paper from source
buildpaper:
    @typst compile "{{PAPER}}.typ"

# Rebuild PDF and refresh the browser
run: buildpaper
    @xdotool search --all --desktop 0 --name "firefox" key --clearmodifiers "F5"

# Runs source code linters
lint:
    @go vet {{TARGETS}}
    @gosec -quiet -fmt=golint -exclude-dir="tmp" ./...

test: 
    @go test -v -coverprofile="{{COVER}}.out" {{TARGETS}}

# Generate pretty coverage report
cover:
    go tool cover -html="{{COVER}}.out" -o="{{COVER}}.html"
    firefox "{{COVER}}.html"

# Updates 3rd party packages and tools
deps:
    go get -u {{TARGETS}}
    go mod tidy
    go install github.com/securego/gosec/v2/cmd/gosec@latest

# Removes all built stuff
clean:
    test ! -f "{{PAPER}}.pdf" || rm "{{PAPER}}.pdf"
    test ! -f "{{COVER}}.*" || rm "{{COVER}}.*"
    go clean
    
