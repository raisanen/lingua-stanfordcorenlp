JAVAC     = javac
JAR       = jar -cf
BIN       = LinguaSCNLP.jar
SOURCEDIR = be/fivebyfive/lingua/stanfordcorenlp
JFLAGS    = -classpath ../lib/Lingua/StanfordCoreNLP/stanford-corenlp-?.?.?.jar -sourcepath . -g:none
SOURCES   = $(wildcard $(SOURCEDIR)/*.java)
CLASSES   = $(SOURCES:.java=.class)

all: $(CLASSES)
	$(JAR) $(BIN) $(CLASSES)

clean :
	rm -f $(CLASSES)
	rm -f $(BIN)

%.class : %.java
	$(JAVAC) $(JFLAGS) $<
