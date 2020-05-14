DIST = docs
ELM = $(shell find src/ -name '*.elm')
HTML = $(DIST)/index.html

ELM_META = elm.json
ELM_MAIN = src/Main.elm

$(HTML) : $(ELM_MAIN) $(ELM) $(ELM_META)
	npx elm make $< --output $@ --optimize

.PHONY: clean
clean :
	rm -rf docs/*
