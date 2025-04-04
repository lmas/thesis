
PAPER := "thesis"

# Show available recipes by default
default:
    @just --list

# Rebuild the book from source
build:
    @typst compile "{{PAPER}}.typ"

# Rebuild PDF and refresh the browser
run: build
    @xdotool search --all --desktop 0 --name "firefox" key --clearmodifiers "F5"

# Removes all built stuff
clean:
    test ! -f "{{PAPER}}.pdf" || rm "{{PAPER}}.pdf"
