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
-c	set item category to channel title
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

# remove attributes, comments, processing instructions, prologs,
# and self-closed elements in hxpiped xml
cleanxml()
{
	grep -v '^[A*?!|]' "$@"
}

# remain only wanted elements in hxpiped-cleanxmled rss
cleanrss()
{
	awk -v nodate="$nodate" '
		function join(a,	i, s) {
			for (i = 0; i < n; i++)
				s = s a[i]
			return s
		}
		BEGIN {
			allowpaths = \
				"<rss><channel><title>\n" \
				"<rss><channel><item><title>\n" \
				"<rss><channel><item><link>\n" \
				"<rss><channel><item><description>\n" \
				"<rss><channel><item><guid>\n" \
				"<rss><channel><item><author>\n"
			if (!nodate)
				allowpaths = allowpaths \
					"<rss><channel><item><pubDate>\n"
			split(allowpaths, allow)
		}
		/^\(/ {
			stack[n++] = "<" substr($0, 2) ">"
		}
		{
			path = join(stack)
			for (i in allow)
				if (index(allow[i], path) == 1) {
					print
					break
				}
		}
		/^\)/ {
			n--
		}
	' "$@"
}

[ "$1" = "--help" ] && { help; exit 0;}
[ "$1" = "--version" ] && { pversion; exit 0;}
ch_title="OneRSS"
ch_desc="Merged Channel"
ch_link="https://github.com/dongyx/onerss"
prepend=0
nodate=0
setcateg=0
while getopts pct:d:l: opt; do
	case $opt in
	p)	prepend=1;;
	c)	setcateg=1;;
	t)	ch_title="$OPTARG";;
	d)	ch_desc="$OPTARG";;
	l)	ch_link="$OPTARG";;
	D)	nodate=1;;
	?)	help >&2; exit -- -1;;
	esac
done
shift $((OPTIND - 1))

d=$(mktemp -d)
if [ $# -eq 0 ]; then
	n=$(hxpipe | cleanxml | cleanrss | awk -v "d=$d" '
		BEGIN {
			n = 0
		}
		/^\(rss$/ {
			if (n++ > 0)
				close (d "/" n)
		}
		{
			print >> (d"/"n)
		}
		END {
			print n
		}
	')
else
	n=0
	for file; do
		<"$file" hxpipe | cleanxml | cleanrss >"$d/$((++n))"
	done
fi
set -- $(seq $n | xargs printf " $d/%s")

(
cat <<.
?xml version="1.0" encoding="UTF-8"?
Aversion CDATA 2.0
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
	chan="$(<"$file" awk '
		/^\(/ { lvl++ }
		/^\)/ { lvl-- }
		/^\(title$/ { title = 1 }
		/^\)title$/ { title = 0 }
		title && lvl == 3 && /^-/ { print; exit }
	')"
	<"$file" awk '/^\(item$/, /^\)item$/' |
	awk -v chan="$chan" -v prepend="$prepend" -v setcateg="$setcateg" '
		/^\(title$/ { title = 1 }
		/^\)title$/ { title = 0 }
		title && prepend && /^-/ { $0 = chan ": " substr($0, 2) }
		/\(guid/ { print "AisPermaLink CDATA false" }
		setcateg && /^\)item$/ {
			print "(category\n" chan "\n" ")category"
		}
		{ print }
	'
done

cat <<.
)channel
)rss
-\n
.
) | hxunpipe

rm -rf "$d"
