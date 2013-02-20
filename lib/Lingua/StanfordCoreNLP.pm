package Lingua::StanfordCoreNLP;

use strict;
#use warnings;

our ($JAR_PATH, $JAVA_ARGS);

BEGIN {
	use Config;
	use File::Spec;
	use Env qw($LINGUA_CORENLP_JAR_PATH $LINGUA_CORENLP_VERSION $LINGUA_CORENLP_JAVA_ARGS);

	use Exporter ();
	our @ISA       = qw(Exporter);
	our @EXPORT    = ();
	our $VERSION   = '0.11';
	    $VERSION   = eval $VERSION;

	our $CORENLP_VERSION = defined $LINGUA_CORENLP_VERSION
		? $LINGUA_CORENLP_VERSION
		: '1.3.4';

	$JAVA_ARGS = defined $LINGUA_CORENLP_JAVA_ARGS
		? $LINGUA_CORENLP_JAVA_ARGS
		: '-Xmx2000m';

	my ($mod_path) = __FILE__ =~ /(.*)\.pm/;
	my $pkg_path = defined $LINGUA_CORENLP_JAR_PATH ? $LINGUA_CORENLP_JAR_PATH : $mod_path;
	my @jar_files;

	if ($pkg_path =~ /\*\.jar$/) {
		@jar_files = glob($pkg_path);
	} else {
		@jar_files = map { File::Spec->catfile($pkg_path, $_); } qw(
			stanford-corenlp-$$.jar
			stanford-corenlp-$$-models.jar
			joda-time.jar
			jollyday.jar
			xom.jar
		);
	}
	push @jar_files, File::Spec->catfile($mod_path, 'LinguaSCNLP.jar');

	$JAR_PATH = join($Config{'path_sep'}, @jar_files);
	$JAR_PATH =~ s/\$\$/$CORENLP_VERSION/g;
}

use Inline (
	Java            => 'DATA',
	CLASSPATH       => $JAR_PATH,
	EXTRA_JAVA_ARGS => $JAVA_ARGS,
	AUTOSTUDY       => 1
);

1;

__DATA__
__Java__
class Pipeline extends be.fivebyfive.lingua.stanfordcorenlp.Pipeline {
	public Pipeline() {
		this(new java.util.Properties());
	}
   public Pipeline(java.util.Properties props) {
		super(props);
	}
}
__END__

=head1 NAME

Lingua::StanfordCoreNLP - A Perl interface to Stanford's CoreNLP tool set.

=head1 SYNOPSIS

The following example demonstrates how to use all the supported annotators of
Lingua::StanfordCoreNLP:
   
 # Note that Lingua::StanfordCoreNLP can't be instantiated.
 use Lingua::StanfordCoreNLP;

 # Create a new NLP pipeline:
 my $pipeline = new Lingua::StanfordCoreNLP::Pipeline();

 # Get annotator properties:
 my $props = $pipeline->getProperties();

 # These are the default annotator properties:
 $props->setProperty('annotators', 'tokenize, ssplit, pos, lemma, ner, parse, dcoref');

 # This is the default dependency-parsing mode (see man-page under PROPERTIES for info):
 $props->setProperty('lingua.dependency-mode', 'collapsed');

 # Update properties:
 $pipeline->setProperties($props);

 # Process text
 # (Will output lots of debug info from the Java classes to STDERR.)
 my $result = $pipeline->process(
    'Jane looked at the IBM computer. She turned it off.'
 );

 # Print results
 for my $sentence (@{$result->toArray}) {
    print "\n[Sentence ID: ", $sentence->getIDString, "]:\n";
    print "Original sentence:\n\t", $sentence->getSentence, "\n";

    print "Tagged text:\n";
    for my $token (@{$sentence->getTokens->toArray}) {
       printf "\t%s/%s/%s [%s]\n",
              $token->getWord,
              $token->getPOSTag,
              $token->getNERTag,
              $token->getLemma;
    }

    print "Dependencies:\n";
    for my $dep (@{$sentence->getDependencies->toArray}) {
       printf "\t%s(%s-%d, %s-%d) [%s]\n",
              $dep->getRelation,
              $dep->getGovernor->getWord,
              $dep->getGovernorIndex,
              $dep->getDependent->getWord,
              $dep->getDependentIndex,
              $dep->getLongRelation;
    }

    print "Coreferences:\n";
    for my $corefChain (@{$sentence->getCorefChains->toArray}) {
       if ($corefChain->isMultiSentence) {
          my $repMention = $corefChain->getRepresentativeMention;
          my @mentions   = map { $_->toString} @{$corefChain->getMentions->toArray};
          printf "\t%s =>\n", $repMention->toString;
          print  "\t\t",  join(' <=> ', @mentions), "\n";
       }
    }
 }

The example code should output (other than debug info from the CoreNLP toolkit) something similar to:

 [Sentence ID: 80000000-0000-0000-8000-000000000001]:
 Original sentence:
    Jane looked at the IBM computer.
 Tagged text:
    Jane/NNP/PERSON [Jane]
    looked/VBD/O [look]
    at/IN/O [at]
    the/DT/O [the]
    IBM/NNP/ORGANIZATION [IBM]
    computer/NN/O [computer]
    ././O [.]
 Dependencies:
    nsubj(looked-1, Jane-0) [nominal subject]
    det(computer-5, the-3) [determiner]
    nn(computer-5, IBM-4) [nn modifier]
    prep_at(looked-1, computer-5) [prep_collapsed]
 Coreferences:
    Jane [@0:0-1] =>
       Jane [@0:0-1] <=> She [@1:0-1]
    the IBM computer [@0:3-6] =>
       the IBM computer [@0:3-6] <=> it [@1:2-3]

 [Sentence ID: 80000000-0000-0000-8000-000000000002]:
 Original sentence:
    She turned it off.
 Tagged text:
    She/PRP/O [she]
    turned/VBD/O [turn]
    it/PRP/O [it]
    off/RP/O [off]
    ././O [.]
 Dependencies:
    nsubj(turned-1, She-0) [nominal subject]
    dobj(turned-1, it-2) [direct object]
    prt(turned-1, off-3) [phrasal verb particle]
 Coreferences:


=head1 DESCRIPTION

This module implements a C<StanfordCoreNLP> pipeline for annotating
text with part-of-speech tags, dependencies, lemmas, named-entity tags, and coreferences.

(Note that the archive contains the CoreNLP annotation models, which is why
it's so darn big. Also note that versions before 0.11 have different API:s for
coreferences from 0.11+.)


=head1 INSTALLATION

The following should do the job:

 $ perl Build.PL
 $ ./Build test
 $ sudo ./Build install

If you want to rebuild the C<LinguaSCNLP.jar> file containing the lion's share of the
functionality of Lingua::StanfordCoreNLP, run C<make> in the C<src> directory, then
copy the resulting C<LinguaSCNLP.jar> into C<lib/Lingua/StanfordCoreNLP> before
doing C<perl Build.PL>.


=head1 PREREQUISITES

Lingua::StanfordCoreNLP consists mainly of Java code, and thus needs L<Inline::Java> installed
to function.


=head1 ENVIRONMENT

Lingua::StanfordCoreNLP can use the following environmental variables

=head2 LINGUA_CORENLP_JAR_PATH

Directory containing the CoreNLP jar-files. Normally, Lingua::StanfordCoreNLP expects
LINGUA_CORENLP_JAR_PATH to contain the following files:

 stanford-corenlp-VERSION.jar
 stanford-corenlp-VERSION-models.jar
 joda-time.jar
 jollyday.jar
 xom.jar

(Where VERSION is 1.3.4 or the value of LINGUA_CORENLP_VERSION.)
If your filenames are different, you can add C<*.jar> to the end of the path, to make
Lingua::StanfordCoreNLP use all the jar-files in LINGUA_CORENLP_JAR_PATH.

=head2 LINGUA_CORENLP_VERSION

Version of jar-files in LINGUA_CORENLP_JAR_PATH.

=head2 LINGUA_CORENLP_JAVA_ARGS

Arguments to pass to JVM (via L<Inline::Java>). Defaults to C<-Xmx2000m> (increase max
memory to 2000 MB).


=head1 PROPERTIES

Properties are set using the L<setProperties>-method on L<Lingua::StanfordCoreNLP::Pipeline>.
Properties can be used to change the behaviour of the annotators; see the CoreNLP documentation
for information on annotator-properties. One Lingua::StanfordCoreNLP-specific property is available:
C<lingua.dependency-mode>, which controls which type of dependency annotation is returned.

There are three possible values for C<lingua.dependency-mode>:

=over

=item "basic"

Basic, uncollapsed dependencies using BasicDependenciesAnnotation.

=item "collapsed"

Collapsed dependencies using CollapsedDependenciesAnnotation.

=item "processed"

Collapsed dependencies with processed coordinations using CollapsedCCProcessedDependenciesAnnotation.

=back

The default mode is "processed".


=head1 EXPORTED CLASS

Lingua::StanfordCoreNLP exports the following Java-classes via L<Inline::Java>:


=head2 Lingua::StanfordCoreNLP::Pipeline

The main interface to C<StanfordCoreNLP>. This class is the only one you
can instantiate yourself. It is, basically, a perlified be.fivebyfive.lingua.stanfordcorenlp.Pipeline.

=over

=item new

=item new($properties)

Creates a new C<Lingua::StanfordCoreNLP::Pipeline> object. The optional
parameter C<$properties> is used to pass options to the StanfordCoreNLP
pipeline. See C<getProperties> and C<setProperties>.

=item getProperties

Returns a C<java.util.Properties> object containing annotator options. By default
it contains two entries: "annotators" which has the value "tokenize, ssplit, pos,
lemma, ner, parse, dcoref", and "lingua.dependency-mode" which has the value
"processed".

=item setProperties($prop)

Updates annotator options. Expects a C<java.util.Properties> object. If you call
this after having called C<process>, you will have to call C<initPipeline> to
update the annotator.

=item getPipeline

Returns a reference to the C<StanfordCoreNLP> pipeline used for annotation.
You probably won't want to touch this.

=item initPipeline

Reinitializes the C<StanfordCoreNLP> pipeline used for annotation.

=item process($str)

Process a string. Returns a C<Lingua::StanfordCoreNLP::PipelineSentenceList>.

=back


=head1 JAVA CLASSES

In addition, Lingua::StanfordCoreNLP indirectly exports the following Java-classes,
all belonging to the namespace C<be.fivebyfive.lingua.stanfordcorenlp>:


=head2 PipelineItem

Abstract superclass of C<Pipeline{CorefMention,Dependency,Sentence,Token}>. Contains ID
and methods for getting and comparing it.

=over

=item getID

Returns a C<java.util.UUID> object which represents the item's ID.

=item getIDString

Returns the ID as a string.

=item identicalTo($b)

Returns true if C<$b> has an identical ID to this item.

=back


=head2 PipelineCorefChain

An object representing a chain of coreferences, consisting of a representative mention and
references to it.

=over

=item getMentions

Returns a C<PipelineCorefMentionList> of mentions to the representative mention.

=item isMultiSentence

Returns true if the chain covers more than one sentence.

=item getRepresentativeMention

Returns a C<PipelineCorefMention> representing the representative mention in the chain.

=item toString

Return the chain as a string in the format "Repr. mention => mention <=> mention <=> ...".

=back


=head2 PipelineCorefMention

An object representing a coreference mention.
Note that both sentences and words are zero-indexed, unlike the default outputs of Stanford's tools.

=over

=item getStartIndex

Get index of the first token (word) of the mention.

=item getEndIndex

Get (one past) index of the last token of the mention.

=item getHeadIndex

Get the index of the "head word" of the mention.

=item getSentNum

Get the index of the sentence in which the mention is found.

=item getTokens

Get the tokens of the mention as a C<PipelineTokenList>.

=item getHeadToken

Get the head-word token of the mention.

=item toString

Get a string representation of the mention, of the format "mention [@sentNum:startIndex-endIndex]".

=back


=head2 PipelineDependency

Represents a dependency in the Stanford Typed Dependency format.
For example, in the fragment "Walk hard", "Walk" is the governor and "hard"
is the dependent in the relationship "advmod" ("hard" is an adverbial modifier
of "Walk").

=over

=item getGovernor

The governor in the relation as a C<PipelineToken>.

=item getGovernorIndex

The index of the governor within the sentence.

=item getDependent

The dependent in the relation as a C<PipelineToken>.

=item getDependentIndex

The index of the dependent within the sentence.

=item getRelation

Short name of the relation.

=item getLongRelation

Long description of the relation.

=item toCompactString

=item toCompactString($includeIndices)

=item toString

=item toString($includeIndices)

Returns a String representation of the dependency --- "relation(governor-N, dependent-N) [description]".
C<toCompactString> does not include description. The optional parameter C<$includeIndices> controls
whether governor and dependent indices are included, and defaults to true.
(Note that unlike those of, e.g., the Stanford Parser, these indices start at zero, not one.)

=back


=head2 PipelineSentence

An annotated sentence, containing the sentence itself, its dependencies,
pos- and ner-tagged tokens, and coreferences.

=over

=item getSentence

Returns a string containing the original sentence

=item getTokens

A C<PipelineTokenList> containing the POS- and
NER-tagged and lemmaized tokens of the sentence.

=item getDependencies

A C<PipelineDependencyList> containing the dependencies
found in the sentence.

=item getCorefChains

A C<PipelineCorefChainList> of the coreference chains between
this and other sentences.

=item toCompactString

=item toString

A String representation of the sentence, its coreferences, dependencies, and tokens.
C<toCompactString> separates fields by "\n", whereas C<toString> separates them by
"\n\n".

=back


=head2 PipelineToken

A token, with POS- and NER-tag and lemma.

=over

=item getWord

The textual representation of the token (i.e. the word).

=item getPOSTag

The token's Part-of-Speech tag.

=item getNERTag

The token's Named-Entity tag.

=item getLemma

The lemma of the the token.

=item toCompactString

=item toCompactString($lemmaize)

A compact String representation of the token --- "word/POS-tag". If the
optional argument C<$lemmaize> is true, returns "lemma/POS-tag".

=item toString

A String representation of the token --- "word/POS-tag/NER-tag [lemma]".

=back


=head2 PipelineList

=head2 PipelineCorefChainList

=head2 PipelineCorefMentionList

=head2 PipelineDependencyList

=head2 PipelineSentenceList

=head2 PipelineTokenList

C<PipelineList> is a generic list class which
extends C<java.Util.ArrayList>. It is in turn extended by
C<Pipeline{CorefChain,CorefMention,Dependency,Sentence,Token}List> (which are the
list-types that C<Pipeline> returns). Note that all lists are zero-indexed.

=over

=item joinList($sep)

=item joinListCompact($sep)

Returns a string containing the output of either the C<toString> or
C<toCompactString> methods of the elements in C<PipelineList>, separated
by C<$sep>.

=item toArray

Return the elements of the list as an array-reference.

=item toHashMap

Return the list as a C<< java.util.HashMap<String,PipelineItem> >>, with
items' stringified ID:s as keys.

=item toCompactString

=item toString

Returns the elements of the C<PipelineList> as a string containing the output
of either their C<toCompactString> or C<toString> methods, separated by the
default separator (which is "\n" for all lists except C<PipelineTokenList>
which uses " ").

=back


=head1 TODO

See L<https://github.com/raisanen/lingua-stanfordcorenlp/issues>.


=head1 REQUESTS & BUGS

Please file any issues, bug-reports, or feature-requests at L<https://github.com/raisanen/lingua-stanfordcorenlp>.


=head1 AUTHORS

Kalle RE<auml>isE<auml>nen E<lt>kal@cpan.orgE<gt>.


=head1 COPYRIGHT

=head2 Lingua::StanfordCoreNLP (Perl bindings)

Copyright E<copy> 2011-2013 Kalle RE<auml>isE<auml>nen.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.


=head2 Stanford CoreNLP tool set

Copyright E<copy> 2010-2012 The Board of Trustees of The Leland Stanford
Junior University.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, see L<http://www.gnu.org/licenses/>.


=head1 SEE ALSO

L<http://nlp.stanford.edu/software/corenlp.shtml>,
L<Text::NLP::Stanford::EntityExtract>,
L<NLP::StanfordParser>,
L<Inline::Java>.

=cut
