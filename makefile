run: ; love .

count: ; cloc *.fnl --force-lang=clojure

VERSION=0.1.0
REL="$(PWD)/love-release.sh"
FLAGS=-a 'Phil Hagelberg and Dan Larkin' \
	--description 'A game of exploration.' \
	--love 11.1 --url https://technomancy.itch.io/exo-encounter-667 \
	--version $(VERSION)

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))

check: $(OUT)
	luacheck --std luajit+love+fennel $(OUT)

clean: ; rm -rf releases/* $(OUT) lib/fennelview.lua

%.lua: %.fnl ; fennel --compile --correlate $< > $@
lib/fennelview.lua: lib/fennelview.fnl ; fennel --compile $< > $@

releases/exo-$(VERSION).love: $(LUA) $(OUT) $(LIBS) lib/fennelview.lua assets
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: releases/exo-$(VERSION).love

mac: love
	$(REL) $(FLAGS) --lovefile releases/exo-$(VERSION).love -M
	mv releases/Exo-macosx-x64.zip releases/exo-$(VERSION)-macosx-x64.zip

windows: love
	$(REL) $(FLAGS) --lovefile releases/exo-$(VERSION).love -W32
	mv releases/Exo-win32.zip releases/exo-$(VERSION)-windows.zip
