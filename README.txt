Obsolete
********

The script is slow. I have seen it take anywhere between few minutes
and few hours

There is a one line wget command that can do the same thing faster

Just use wget
=============

wget -r -nc "start page url"

Or tar if tar file available
============================

tar -xzf file.tar.gz


save-html-book-offline.sh
*************************

Dependencies
============

* curl
* wget

How to
======

The script requires the url of the book's start page and optionally
the book's max height. For example:

alias hb="bash /path-to/save-html-book-offline.sh"
hb https://www.gnu.org/software/easejs/manual/ 2

Options
=======

url 
	The url of the start page

height
	Optional, default = 1
	When to stop looking for more pages to download

Example 
-------

hb https://xyz.com/a.html 2

Say a.html links to b1.html and b2.html 
and say b2.html links to c.html 
then depending on height the following happens

0	download start page
		a.html
1	and download resources linked on a.html
		b1.html
		b2.html
2	and download resources linked on b1.html, b2.html
		c.html

Notes
=====

No folders
----------

All files are stored in the same directory and cross domain pages are
ignored

	https://abc.com/s1/s2/a.png
	becomes the file abc.com.s1.s2.a.png

Start page save twice
---------------------

The start page is saved once more as index.html, so that it is opened
by default when visitng the book directory in browser


Have I used this script?
========================

Yeah, but I do not use it anymore. Many times I just get the pdf or
txt

