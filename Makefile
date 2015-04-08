all: header.html footer.html
	pandoc -o tmp.html ${ARGS} 
	cat header.html tmp.html footer.html > ${ARGS:.md=.html}
	rm tmp.html
