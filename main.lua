-- bootstrap the compiler
fennel = require("lib.fennel")
table[("insert")](package[("loaders")], fennel[("searcher")])
pp = function(x) print(require("lib.fennelview")(x)) end

fennel.dofile("main.fnl")
