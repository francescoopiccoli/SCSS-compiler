# todo: rivedere da zero

proj_name=flc
build_dir=build


all: clean .flex .yacc .gcc .cleanwd
	

run: 
	$(build_dir)/$(proj_name)

.flex:
	@echo "Running flex..."
    	# -l, --lex-compat maximal compatibility with original lex cd into build directory, note the semicolon and rule in one line     -d to add debug mode
	flex -l *.l

.yacc:
	@echo "Running yacc..."
	#-v: generates the DFA -d: generate the y.tab.h file
	yacc -vd *.y    


.gcc:
	@echo "Compiling with GNU compiler..."
    #the - in front of command forces make to continue even with errors
	gcc y.tab.c -ly -g -ggdb -o $(build_dir)/$(proj_name) 


.cleanwd:
	mv y.* lex.yy.c ./$(build_dir)/

clean:
	mkdir -p $(build_dir)

test:
	$(build_dir)/$(proj_name).out test.in


