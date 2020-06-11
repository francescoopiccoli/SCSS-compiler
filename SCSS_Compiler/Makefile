# Simple makefile for scss-parse

proj_name=scss-parse
build_dir=build

all: clean
	# make dir if doesn't exist
	mkdir -p $(build_dir)
	# compile all lex files
	- flex -l *.l
	# build yacc parser
	- yacc -vd *.y
	# compile final C program
	- gcc y.tab.c -lm -ly -g -ggdb -o $(build_dir)/$(proj_name) 
	# move leftovers to build folder
	mv y.* lex.yy.c ./$(build_dir)/

clean:
	# remove build folder
	rm -rf ./$(build_dir)/

install:
	# install binary system-wide
	install -m 755 $(build_dir)/$(proj_name) /usr/bin
