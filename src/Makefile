JAVAC     = javac
JAR       = jar -cf
BIN       = LinguaSCNLP.jar
BINDIR    = ../lib/Lingua/StanfordCoreNLP
SOURCEDIR = be/fivebyfive/lingua/stanfordcorenlp
JFLAGS    = -classpath $(BINDIR)/stanford-corenlp-?.?.?.jar -sourcepath . -g:none
SOURCES   = $(wildcard $(SOURCEDIR)/*.java)
CLASSES   = $(SOURCES:.java=.class)

all: $(CLASSES)
	$(JAR) $(BIN) $(CLASSES)

clean :
	rm -f $(CLASSES)
	rm -f $(BIN)

%.class : %.java
	$(JAVAC) $(JFLAGS) $<

dist: clean all
	cp $(BIN) $(BINDIR)
