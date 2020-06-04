# todo: rivedere da zero

PROJECT=flc
BUILDDIR=build
BUILDOUT=$(PROJECT).out


all: clean .flex .yacc .gcc .cleanwd
	

run: 
	$(BUILDDIR)/$(PROJECT).out 

.flex:
	@echo "Running flex..."
    	# -l, --lex-compat maximal compatibility with original lex cd into build directory, note the semicolon and rule in one line \
	flex -l *.l

.yacc:
	@echo "Running yacc..."
	#-v: generates the DFA -d: generate the y.tab.h file \
	yacc -vd *.y    


.gcc:
	@echo "Compiling with GNU compiler..."
    #the - in front of command forces make to continue even with errors
	gcc y.tab.c -ly -ll -ggdb -o $(BUILDDIR)/$(build_name) 


.cleanwd:
	@echo "Cleanup working directory by moving files to build folder..."
	mv y.* lex.yy.c ./$(BUILDDIR)/

clean:
	@echo "Clean build directory..."

test:
	$(BUILDDIR)/$(PROJECT).out test.in


