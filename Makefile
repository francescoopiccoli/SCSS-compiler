proj_name = flc
build_dir = build
build_name = $(proj_name).out


all: clean .flex .yacc .gcc .cleanwd
	

run: 
	@echo "Starting $(proj_name)..."
	$(build_dir)/$(proj_name).out 

.flex:
	@echo "Running flex..."
    # -l, --lex-compat maximal compatibility with original lex \
    cd into build directory, note the semicolon and rule in one line \
	the - in front of command forces make to continue even with errors
	-flex -l *.l

.yacc:
	@echo "Running yacc..."
    #-v: generates the DFA \
	-d: generate the y.tab.h file \
	the - in front of command forces make to continue even with errors
	-yacc -vd *.y    


.gcc:
	@echo "Compiling with GNU compiler..."
    #the - in front of command forces make to continue even with errors
	-gcc y.tab.c -ly -ll -ggdb -o $(build_dir)/$(build_name) 


.cleanwd:
	@echo "Cleanup working directory by moving files to build folder..."
	mv y.* lex.yy.c ./$(build_dir)/

clean:
	@echo "Clean build directory..."

test:
	$(build_dir)/$(proj_name).out test.in


