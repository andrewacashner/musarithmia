base = interval
web = $(base).w

tex = $(base).tex
prog = $(base).c

exec = build/$(base)
doc = doc/$(base).pdf

dirs = build doc aux

FLAGS = -Wall --ansi --pedantic

.PHONY : all clean

all : $(exec) $(doc)

$(dirs) :
	-mkdir -p $(dirs)

$(exec) : aux/$(prog)
	gcc $(FLAGS) -o $@ $<

aux/$(prog) : $(web) | $(dirs)
	ctangle $< - $@

$(doc) : aux/$(tex)

doc/%.pdf : aux/%.pdf
	mv $< $@

aux/%.pdf : aux/%.tex
	pdftex -output-directory=aux $<

aux/%.tex : %.w | $(dirs)
	cweave $< - $@

view:	$(doc)
	evince $(doc) &> /dev/null &

clean:
	-rm -rf $(dirs)
