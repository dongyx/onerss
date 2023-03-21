.PHONY: clean install hxpipe hxunpipe

INSTALL = install
prefix = /usr/local
bindir = $(prefix)/bin

onerss: onerss.sh hxpipe hxunpipe
	cp $< $@
	chmod +x $@

hxpipe:
	@if ! which $@ >/dev/null; then \
		echo Can\'t find $@.; \
		echo Please install HTML-XML-utils '<https://www.w3.org/Tools/HTML-XML-utils>.'; \
		exit -- -1; \
	fi

hxunpipe:
	@if ! which $@ >/dev/null; then \
		echo Can\'t find $@.; \
		echo Please install HTML-XML-utils '<https://www.w3.org/Tools/HTML-XML-utils>.'; \
		exit -- -1; \
	fi

clean:
	rm -f onerss

install: onerss
	$(INSTALL) -d $(bindir)
	$(INSTALL) $< $(bindir)
