# save-html-book-offline

This is a tool to download resources linked to a given web page
and replace web links with file system links for offline use

## Running
The script takes the url of the book's start page as the first argument
```bash
alias hb="bash /path-to/save-html-book-offline.sh"
hb <url> [<height>]
```

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

0 => download start page a.html
1 => and download pages linked on a.html i.e b1.html and b2.html
2 => and download pages linked on b1.html and b2.html i.e c.html
```

## Some gotchas
- All files are stored in the same directory as follows: File available at `https://abc.com/s1/s2/a.png` is saved and linked to as abc.com.s1.s2.a.png
- The start page is saved once more as index.html, so that it is opened by default when going into the book directory
- Cross domain pages are ignored
