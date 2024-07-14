build:
	zig build
test:
	zig build test
build-release:
	zig build -Doptimize=ReleaseSafe
run:
	./zig-out/bin/zig-game
