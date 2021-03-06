#----------------------------------------------------------------------
# === UPDATE FLOWGEN DOCUMENTATION ===
#----------------------------------------------------------------------


CCSOURCEFILES := $(shell ls src/*.cpp)
FLOWHTML_FROMCCSOURCEFILES := $(shell ls src/*.cpp | sed s/"src\/"/"flowdoc\/"/)
FLOWDBS_FROMCCSOURCEFILES := $(shell ls src/*.cpp | sed s/"src\/"/"flowdoc\/aux_files\/"/)
FLOWHTML:= $(FLOWHTML_FROMCCSOURCEFILES:.cpp=.html) flowdoc/simple_demo_src.html
FLOWDBS:= $(FLOWDBS_FROMCCSOURCEFILES:.cpp=.flowdb) flowdoc/aux_files/simple_demo_src.flowdb

#$(TMPDIR)/%.txt : src/%.cpp
#	@echo "cc-to-txt: processing $^ to make $@"
#	@echo execute src-to-txt-converter
#	
#flowdoc/%.html : $(TMPDIR)/%.txt
#	@echo "txt-to-html: processing $^ to make $@ (remember to also make pngs)"
#	@echo execute txt-to-html-converter
    
#flowdoc/simple_demo_src.html : simple_demo_src.cpp test.py
#	@echo "a"

all: flowdoc

flowdoc/aux_files/%.flowdb : src/%.cpp simple_demo_src.cpp pretest.py
	@echo "cpp-to-flowdb: preprocessing"
	python3 pretest.py simple_demo_src.cpp
	python3 pretest.py $^
		
flowdoc/aux_files/.runphase: $(CCSOURCEFILES) simple_demo_src.cpp test.py
	@echo "cpp-to-graphs: depends on $^"
	python3 test.py simple_demo_src.cpp
	python3 test.py $^
	cd flowdoc/aux_files && java -jar plantuml.jar *.txt
	cat <<EOF > flowdoc/aux_files/.runphase
	
flowdoc/%.html : flowdoc/aux_files/%.flowdb posttest.py flowdoc/aux_files/.runphase
	@echo "to-html: processing $^ to make $@"
	python3 posttest.py $^
			
flowdoc: simple_demo_src.cpp src/*.cpp $(FLOWDBS) $(FLOWHTML) Makefile flowdoc/aux_files/.runphase 
	@echo "Hopla! Finished flowdoc creation. Check flowdocs."
	
