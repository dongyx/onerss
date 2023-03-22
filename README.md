OneRSS
======

OneRSS is a Unix command-line project which merges multiple RSS feeds into one.

OneRSS aims to provide most functions with fewest options.

* [Examples](#examples)
* [Installation](#installation)
* [Usage](#usage)

Examples
========

The `onerss` program prints the merged feed to the standard output.

- Merge local feeds

	~~~
	onerss feed1.xml feed2.xml
	~~~

	or

	~~~
	cat feed1.xml feed2.xml | onerss
	~~~

- Merge remote feeds

	~~~
	curl https://example.com/feed1.xml https://example.com/feed2.xml | onerss
	~~~

- Merge mixed feeds

	~~~
	(
		curl https://example.com/feed1.xml
		cat feed2.xml
	) | onerss
	~~~

- Specify the title of the merged feed by `-t`
	
	~~~
	onerss -t 'Merged News' feed1.xml feed2.xml feed3.xml
	~~~

- Prepend sub-feed titles to item titles by `-p`

	~~~
	onerss -p feed1.xml feed2.xml
	~~~

- Rename sub-feeds

	As described above, if `onerss` is called with the `-p` option, sub-feed titles will be prepended to item titles in the merged feed.
	However, sometimes we want to change sub-feed titles.
	The following snippet demonstrates the approach.

	~~~
	(
		onerss -t Name1 feed1.xml
		curl https://example.com/feed2.xml | onerss -t Name2

	) | onerss -pt 'Merged News'
	~~~

	**Explanation:** The `onerss` program provides the `-t` option to set the title of the merged feed.
	Thus applying `onerss` to a single feed with the `-t` option renames the feed.
	Then we pipe renamed feeds to another `onerss` process for merging.

- Merge Atom feeds and RSS feeds

	The `onerss` program doesn't support Atom naively.
	However, we could pipe a Atom-to-RSS program[^atom2rss] to `onerss`.

	~~~
	(
		curl https://example.com/atom-feed.xml | atom2rss
		cat rss-feed.xml
	) | onerss
	~~~

Installation
============

Runtime dependencies: 

- W3C's [HTML-XML-utils](https://www.w3.org/Tools/HTML-XML-utils/)

Install OneRSS by the following commands:

	make
	sudo make install

By default, OneRSS is installed to `/usr/local`.

Usage
=====


- `onerss [options] [file...]`

	Options:

		-p          prepend channel title to item title
		-t <title>  set title of merged channel
		-d <desc>   set description of merged channel
		-l <link>   set link of merged channel

- `onerss --help`

	Print the usage

- `onerss --version`

	Print the version

[^atom2rss]: The `atom2rss` utility in the snippet is a simple shell wrapper of Kornel's [`atom2rss.xsl`](https://github.com/kornelski/atom2rss).
