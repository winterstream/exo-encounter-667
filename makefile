VERSION=0.1.0
NAME=exo
URL=https://technomancy.itch.io/exo-encounter-667
AUTHOR="Phil Hagelberg and Dan Larkin"
DESCRIPTION="A game of exploration."
run: ; love .

count: ; cloc *.fnl --force-lang=clojure

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))

check: $(OUT)
	luacheck --std luajit+love+fennel $(OUT)

clean: ; rm -rf releases/* $(OUT)

%.lua: %.fnl ; fennel --compile --correlate $< > $@

LOVEFILE=releases/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(OUT) $(LIBS) assets text
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL="$(PWD)/love-release.sh" # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love 11.1 --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

releases/$(NAME)-$(VERSION)-macos.zip: love
	$(REL) $(FLAGS) -M

mac: releases/$(NAME)-$(VERSION)-macos.zip

windows: love
	$(REL) $(FLAGS) -W32
