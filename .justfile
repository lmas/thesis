COVER := ".cover"
MEM := ".mem.prof"
CPU := ".cpu.prof"

# Show available recipes by default
default:
    @just --list

################################################################################

# Updates 3rd party packages and tools
deps:
    go get -u "./damp"
    go mod tidy
    go install github.com/securego/gosec/v2/cmd/gosec@latest

# Recompile the paper from source
buildpaper:
    @typst compile "thesis.typ"

# Rebuild PDF and refresh the browser
run: buildpaper
    @xdotool search --all --desktop 0 --name "firefox" key --clearmodifiers "F5"

################################################################################

# Runs source code linters
lint:
    go vet "./damp"
    gosec -quiet -fmt=golint "./damp"

# Runs available test suites and saves coverage stats
test: 
    go test -v -coverprofile="{{COVER}}.out" "./damp"

# Generate pretty coverage report from previously saved stats
cover:
    go tool cover -html="{{COVER}}.out" -o="{{COVER}}.html"
    firefox "{{COVER}}.html"

# Run benchmark suites and save both CPU and MEM usage stats
bench:
    go test -test.benchmem -bench=. -cpuprofile "{{CPU}}" -memprofile "{{MEM}}" "./damp"

cpuprof:
    go tool pprof -lines -show "damp" -http=:8080 "{{CPU}}"

memprof:
    go tool pprof -lines -show "damp" -http=:8081 "{{MEM}}"
    

################################################################################

MNT := "./mnt"

buildlogger:
    @test -d "{{MNT}}" || (echo "You must run mount first!" && exit 1)
    GOOS=linux GOARCH=arm64 go build -o "{{MNT}}/logger" logger/*

# Mounts a remote dir for ease of access
mount:
    doas kldload -n fusefs
    test -d "{{MNT}}" || mkdir "{{MNT}}"
    sshfs "hallonpaj:{{MNT}}" "{{MNT}}"

# Cleans up the mount
umount:
    umount "{{MNT}}"
    test ! -d "{{MNT}}" || rmdir "{{MNT}}"
    
################################################################################

# Removes all built stuff
clean:
    rm *.pdf || true
    rm {{COVER}}.* || true
    rm {{MEM}} || true
    rm {{CPU}} || true
    rm *.test || true
    rm damp/samples/*.damp || true
    go mod tidy
    go clean
    
