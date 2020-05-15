DIST = docs
ELM = $(shell find src/ -name '*.elm')
JS = $(DIST)/main.js

ELM_META = elm.json
ELM_MAIN = src/Main.elm

$(JS) : $(ELM_MAIN) $(ELM) $(ELM_META)
	npx elm make $< --output $@ --optimize

.PHONY: clean
clean :
	rm -rf docs/*
