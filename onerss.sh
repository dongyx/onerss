#!/bin/sh

set -e
progname=onerss
version=0.0.1
author='DONG Yuxuan <https://www.dyx.name>'

help()
{
	cat <<.
Usage:
	$progname [options] [file...]
Options:
.
	column -ts'	' <<. | awk '{print "\t" $0}'
-p	prepend channel title to item title
-t <title>	set title of merged channel
-d <desc>	set description of merged channel
-l <link>	set link of merged channel
.
}

pversion()
{
	cat <<.
$progname $version
Copyright (c) 2023 $author
.
}

[ "$1" = "--help" ] && { help; exit 0;}
[ "$1" = "--version" ] && { pversion; exit 0;}
ch_title="OneRSS"
ch_desc="Merged Channel"
ch_link="https://github.com/dongyx/onerss"
prepend=0
while getopts pt:d:l: opt; do
	case $opt in
	p)	prepend=1;;
	t)	ch_title="$OPTARG";;
	d)	ch_desc="$OPTARG";;
	l)	ch_link="$OPTARG";;
	?)	help >&2; exit -- -1;;
	esac
done
shift $((OPTIND - 1))

preproc=hxpipe
d=''
if [ $# -eq 0 ]; then
	d=$(mktemp -d)
	preproc=cat
	n=$(hxpipe | awk -v "d=$d" '
		BEGIN { n = 0 }
		/^\(channel$/ { if (n++ > 0) close (d"/"n)}
		/^\(channel$/, /^\)channel$/ { print >> (d"/"n) }
		END { print n }
	')
	set -- $(seq $n | xargs printf " $d/%s")
fi

(
cat <<.
?xml version="1.0" encoding="UTF-8"?
Aversion CDATA 2.0
Axmlns:atom CDATA http://www.w3.org/2005/Atom
Axmlns:sy CDATA http://purl.org/rss/1.0/modules/syndication/
(rss
(channel
(title
-$ch_title
)title
(description
-$ch_desc
)description
(link
-$ch_link
)link
(generator
-OneRSS &lt;https://github.com/dongyx/onerss&gt;
)generator
.

for file; do
	chan="$("$preproc" "$file" |
		awk '
			/^\(/ { lvl++ }
			/^\)/ { lvl-- }
			/^\(title$/ { title = 1 }
			/^\)title$/ { title = 0 }
			title && lvl == 2 && /^-/ { print substr($0, 2); exit }
		'
	)"
	"$preproc" "$file" |
	awk '/^\(item$/, /^\)item$/' |
	awk -v chan="$chan" -v prepend="$prepend" '
		/^\(title$/ { title = 1 }
		/^\)title$/ { title = 0 }
		title && prepend && /^-/ { $0 = "-" chan ": " substr($0, 2) }
		1
	'
done

cat <<.
)channel
)rss
-\n
.
) | hxunpipe

[ -n "$d" ] && rm -rf "$d"
