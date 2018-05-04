VERSION=0.1.0
NAME=exo
URL=https://technomancy.itch.io/exo-encounter-667
AUTHOR="Phil Hagelberg and Dan Larkin"
DESCRIPTION="A game of exploration."

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))

run: $(OUT) ; love .

count: ; cloc *.fnl --force-lang=clojure

check: $(OUT)
	luacheck --std luajit+love+fennel $(OUT)

clean: ; rm -rf releases/* $(OUT)

TEXT ?= first

textview:
	urxvt -fn "xft:Fixedsys Excelsior 3.01:style=Regular" -e less text/$(TEXT)

%.lua: %.fnl ; lua lib/fennel --compile --correlate $< > $@

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

releases/$(NAME)-$(VERSION)-win.zip: love
	$(REL) $(FLAGS) -W32

mac: releases/$(NAME)-$(VERSION)-macos.zip
windows: releases/$(NAME)-$(VERSION)-win.zip
