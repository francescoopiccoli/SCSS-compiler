# todo: rivedere da zero

proj_name=flc
build_dir=build


all: clean
	mkdir -p $(build_dir)
	flex -l *.l
	yacc -vd *.y    
	gcc y.tab.c -lm -ly -g -ggdb -o $(build_dir)/$(proj_name) 
	mv y.* lex.yy.c ./$(build_dir)/

clean:
	rm -rf ./$(build_dir)/

install:
	install -m 755 $(build_dir)/$(proj_name) /usr/bin
