# Binary for Java (B4J)

XML Data Encoding / Decoding Tool for Java MIDP/DOJA (2004–2005)

## Rationale

In the early days of Java applications on mobile phones,
memory and storage were counted in mere KB, not in MB.
Connectivity was limited and downloads of the code and data
of the application were metered on expensive data plans.

Even the most simple games typically require a large amount
of data to represent each level, in a format which varies
depending on the nature of the game. This data can be
conveniently represented in XML, and created by level
designers using custom level editors on a computer.

In order to embed that data in the game, it needs to be
compressed, typically encoded in a binary format and
decoded using a custom decoder, which has to be written
for each new game. This is tedious prone to error.

The Binary for Java tool streamlines the creation of custom
encoders and decoders for XML data, using an XML Schema
annotated with semantic actions written in Java. The generated
decoder compresses the data into a compact binary format
while the generated decoders extracts that data and provides
it as building blocks to the semantic actions to create
objects needed by the application, such as game levels.

## Requirements

* [Java JDK 1.4 or higher](https://openjdk.java.net/)
* [Apache Ant 1.6.1 or higher](https://ant.apache.org/)

## Usage

1. *Bring your own XML document*
2. *Configure properties at the top of the build.xml*
3. Create an empty schema: `ant createEmptySchema`
4. *Edit the schema to list the elements found in your XML document*
5. Add complex types to the schema: `ant addSchemaTypes`
6. *Edit the schema to add attributes and children in the complex types*
7. Validate the schema: `ant validateData`
8. *Encode your XML document to binary: `ant encoding`*
9. Test decoding: `ant testDecoding`
10. Add annotations for semantic actions to the schema: `ant addSemanticActions`
11. *Edit the schema to add your Java code (semantic actions) in annotations*
12. Generate Java decoder: `ant generateDecoder`

These steps are described in details in the online [tutorial][],
applied to the example of a quiz game.

[tutorial]: https://eric-brechemier.github.io/b4j/doc/tutorial/chapter1/

## Documentation

* [Overview](https://eric-brechemier.github.io/b4j/doc/overview/overview.pdf)
* [Quick Start in 5 Steps](https://eric-brechemier.github.io/b4j/doc/quickStart/quickStart.pdf)
* [Directory Tree](https://eric-brechemier.github.io/b4j/doc/directoryTree/directoryTree.pdf)

*Some context information about the project,
its partners and technologies
is available in French,  
from the presentation at the end of my
Master in Video Games and Interactive Media:*

* [Project Report for my Master Degree](https://eric-brechemier.github.io/b4j/doc/education/EricBrechemier_Automatiser_le_passage_des_donnees_aux_objets_java.pdf)
* [Slides for the project presentation in December 2004](https://eric-brechemier.github.io/b4j/doc/education/EricBrechemier_Presentation_EricBrechemier_Automatiser_le_passage_des_donnees_aux_objets_java.pdf)
* [XSLT Orienté Objets / Object Oriented XSLT](https://eric-brechemier.github.io/b4j/doc/education/EB_XSLT_OO.pdf)

## Credits

* Author: [Eric Bréchemier](https://github.com/eric-brechemier) (October 2004)
* Concept: [Fabien Delpiano](http://www.pastagames.com/bio/) (May 2004)

## License

[MIT](https://opensource.org/licenses/MIT)
