-- bootstrap the compiler
fennel = require("lib.fennel")
table[("insert")](package[("loaders")], fennel[("searcher")])
debug.traceback = fennel.traceback
pp = function(x) print(require("lib.fennelview")(x)) end
lume = require("lib.lume")

fennel.dofile("main.fnl")
