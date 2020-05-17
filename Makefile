DIST = docs
ELM = $(shell find src/ -name '*.elm')
JS = $(DIST)/main.js

ELM_META = elm.json
ELM_MAIN = src/Main.elm

HTML_IN = src/index.html
NOTICE = $(DIST)/notice.txt
HTML = $(DIST)/index.html

CSS_IN = src/main.css
CSS = $(DIST)/main.css

.PHONY: all
all : $(JS) $(HTML) $(CSS)

$(JS) : $(ELM_MAIN) $(ELM) $(ELM_META)
	npx elm make $< --output $@ --optimize

$(NOTICE) : $(ELM_META)
	script/third_party_notice.sh > $@

$(HTML) : $(HTML_IN) $(NOTICE)
	sed -e "/%third_party_notice%/{r $(NOTICE)" -e "d}"  $< > $@

$(CSS) : $(CSS_IN)
	cp $< $@

.PHONY: clean
clean :
	rm -rf docs/*
