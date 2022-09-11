# save-html-book-offline

A script to download resources linked to a given web page
and replace web links with file system links for offline use

## Dependencies
- curl
- wget

## Running
The script requires the url of the book's start page and optionaly the book's height
```bash
alias hb="bash /path-to/save-html-book-offline.sh"
hb https://www.gnu.org/software/easejs/manual/ 2
```

## When not to use?
The script can take any where between a few seconds to a few hours and so is not a good option when the documentation is available for download for offline use

A lot of the GNU software has html files compressed to a tar.gz file available for download. They can be decompressed as shown below
```bash
wget https://www.gnu.org/software/guile/manual/guile.html_node.tar.gz
gunzip guile.html_node.tar.gz
tar -xf guile.html_node.tar
```
This will unpack all files to the current directory, which can get messy you did not want to mix these files with other files

## Input parameters
- `url` : 
The url of the start page

- `height` : (Optional, default = 1)
When to stop looking for more pages to download

```
example 
hb https://xyz.com/a.html 2
say a.html links to b1.html and b2.html 
and
say b2.html links to c.html 
then 
depending on height given the following happens

0 => download start page `a.html`
1 => and download resources linked on `a.html` i.e `b1.html` and `b2.html`
2 => and download resources linked on `b1.html` and `b2.html` i.e `c.html`
```

## Notes
- All files are stored in the same directory as follows: File available at `https://abc.com/s1/s2/a.png` is saved and linked to as `abc.com.s1.s2.a.png`
- The start page is saved once more as `index.html`, so that it is opened by default when visitng the book directory in browser
- Cross domain pages are ignored

## Have I used this script?
Yes. Many times I could not find downloadable version of some html documntation / html book, so this helped. For example, Nettle, GNU Ease.js, GNU FisicaLab, How to Design Programs

I used this script to get a copy of the Second edition of Structure and Interpretation of Computer Programs from the MIT site before it was not available, so that was pretty neat. Still have to read the book though. Wikipedia mentioned How to Design Programs as a more accessible book, might try reading that first


