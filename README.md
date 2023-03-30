onerss
======

`onerss` is a Unix command-line project which merges multiple RSS 2.0 feeds into one.

`onerss` aims to provide most functions with fewest options.

* [Installation](#installation)
* [Usage](#usage)
* [Documentation](#documentation)

Installation
------------

Runtime dependencies: 

- W3C's [HTML-XML-utils](https://www.w3.org/Tools/HTML-XML-utils/)

Install `onerss` by the following commands:

	make
	sudo make install

By default, `onerss` is installed to `/usr/local`.

Usage
-----

- `onerss [options] [file...]`

	Options:

		-p          prepend channel title to item title
		-c          set item category to channel title
		-t <title>  set title of merged channel
		-d <desc>   set description of merged channel
		-l <link>   set link of merged channel

- `onerss --help`

	Print the usage

- `onerss --version`

	Print the version

Documentation
-------------

See <<https://www.dyx.name/notes/onerss.html>>.
It contains a lot of examples,
from the simplest merging task to the most complicated one.
