<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns="antlib:org.apache.tools.ant"
>
   <!-- 'standard' or 'powerpack' -->
   <xsl:param name="b4j-version" select="'powerpack'" />
   
   <xsl:param name="b4j-version-number" select="'1.1'" />
   
   <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
   
   <!-- 
   Input: Any
   
   Output: Ant build file, either for standard version or for powerpack version of Binary 4 Java,
   according to given 'b4j-version' parameter.
   
   Created:
     by Eric Bréchemier
     on January 5th, 2005
  
   I wrote an ant file to launch this transform; command line example:
   ant -f ant-config.xml -Db4jVersion=standard
   -->
   
   <xsl:variable name="isPowerPackVersion" select="boolean( $b4j-version = 'powerpack' )" />
   
<xsl:template match="/">

<project name="binary4java" basedir="." default="description">
    <xsl:comment>
    
    Project description: Binary for Java Encoder and Decoder Generator
    
       <xsl:call-template name="printB4JVersion" />
    
    Credits:
    Author: Eric Bréchemier, October 2004
    Concept: Fabien Delpiano, May 2004
    
    Uses Saxon, Xalan, Jing, XercesJarv, Artistic Style, Bearlib FP library.
    </xsl:comment>
    
    <xsl:comment> 
      &lt;ONLY PROPERTIES TO MODIFY&gt; 
    </xsl:comment>
      <xsl:comment> 
      This build file was intended for use in two different scenarios:
        * With B4J fully included in your project, 
            - keep project basedir="." and 
            - keep USER.project.dir.path location="."
        * With B4J shared by your different projects, 
            - set project basedir="B4J relative location" and 
            - set USER.project.dir.path to your project location.
      Many thanks for your attention,
      B4J Team
      </xsl:comment>
      <xsl:comment>&lt;property name="USER.project.dir.path" location="C:\programs\eclipse\workspace\USERPROJECT"/&gt;</xsl:comment>
      <property name="USER.project.dir.path" location="."/>
      <xsl:comment> 
        input files 
      </xsl:comment>
      <property name="USER.schema.dir.path" location="${{USER.project.dir.path}}/usr"/>
      <property name="USER.input.data.path" location="${{USER.project.dir.path}}/usr/testSample.xml"/>
      <property name="USER.schema.name" value="NanoSvg.xsd"/>
      <property name="USER.namespace.uri" value="http://eric.brechemier.name/2004/b4j/user-project"/>
      <property name="USER.namespace.prefix" value="usr"/>
      
      <xsl:comment> 
        java destination project 
      </xsl:comment>
      <property name="USER.output.data.dir.path" location="${{USER.project.dir.path}}/data"/>
      <xsl:comment> without extension </xsl:comment>
      <property name="USER.output.data.name" value="gameData"/>
      <xsl:comment> #default for default package </xsl:comment>
      <property name="USER.decoder.java.package" value="#default" />
      <xsl:comment> including package directories </xsl:comment>
      <property name="USER.java.package.dir.path" location="${{USER.project.dir.path}}/src"/> 
      
      <xsl:comment> 
        version 
      </xsl:comment>
      <property name="USER.include.version.number.TRUE" value="set name end to TRUE or FALSE to use this feature" />
      <property name="USER.encoder.version.path" location="${{USER.project.dir.path}}/encoder.version" />
    <xsl:comment>
    &lt;/ONLY PROPERTIES TO MODIFY&gt; 
    
    
    
    
    
    
    </xsl:comment>
    
    
    <xsl:comment> FOLLOWING PROPERTIES SHOULD NOT BE MODIFIED </xsl:comment>
    
    <xsl:comment> Libraries </xsl:comment>
    <property name="lib.path" value="lib"/>
    
    <xsl:comment> Beartronics Fixed Point Library </xsl:comment>
    <property name="fp.jar.path" value="${{lib.path}}/fplib-1.6/beartronics_fp-1.6.jar"/>
    
    <xsl:comment> Michael Kay Saxon </xsl:comment>
    <property name="saxon.jar" value="${{lib.path}}/saxon-6.5.3/saxon.jar"/>
    
    <xsl:comment> Apache Xalan and java extension </xsl:comment>
    <property name="xalan.class" value="org.apache.xalan.xslt.Process"/> <xsl:comment> included in Java JRE </xsl:comment>
    <property name="encoder.java.extension.path" value="src/encoder/java"/>
    <property name="encoder.java.extension.classpath" value="${{fp.jar.path}};${{encoder.java.extension.path}}"/>
    
    <xsl:comment> James Clark Jing, a validator for RELAX NG and other schema languages </xsl:comment>
    <property name="jing.jar" value="{'${lib.path}/jing-20030619/jing.jar'}"/>
    
    <target name="validateSchemaUsingJing">
      <java jar="{'${jing.jar}'}" fork="true">
        <arg value="{'${param.xml.schema}'}"/>
      </java>
    </target>
    
    <target name="validateDataUsingJing">
      <java jar="{'${jing.jar}'}" fork="true">
        <arg value="{'${param.xml.schema}'}"/>
        <arg value="{'${param.xml.data}'}"/>
      </java>
    </target>
    
    <xsl:comment> Sun Multi-Schema XML Validator and Xml Validation </xsl:comment>
    <property name="msv.jar" value="{'${lib.path}/msv-20041031/msv.jar'}"/>
    
    <target name="validateSchemaUsingSunMSV">
      <java jar="{'${msv.jar}'}" fork="true">
        <arg value="{'${param.xml.schema}'}"/>
      </java>
    </target>
    
    <target name="validateDataUsingSunMSV">
      <java jar="{'${msv.jar}'}" fork="true">
        <arg value="{'${param.xml.schema}'}"/>
        <arg value="{'${param.xml.data}'}"/>
      </java>
    </target>
    
    <xsl:comment> Tal Davidson Artistic Style Formatter </xsl:comment>
    <property name="artistic.style.cmd" value="{'${lib.path}/astyle-1.15.3/astyle'}"/>
    <property name="artistic.style.options" value="--style=java --suffix=.before.indent"/>
    
    <target name="indentJavaUsingArtisticStyle">
      <exec executable="{'${artistic.style.cmd}'}">
        <arg line="{'${artistic.style.options}'}"/>
        <arg value="{'${java.file.to.indent}'}"/>
      </exec>
    </target>
    
    <xsl:comment> Oliver Becker XML to HTML Verbatim Formatter with Syntax Highlighting </xsl:comment>
    <property name="pretty.print.path" value="src/utils/prettyPrint"/>
    <property name="pretty.print.css.path" value="{'${pretty.print.path}/xmlverbatim.css'}"/>
    
    <xsl:if test="$isPowerPackVersion">
      <xsl:comment> Eric Bréchemier B4J Power Pack </xsl:comment>
      <property name="powerpack.encoder.src.path" value="src/powerpack/encoder"/>
      <property name="powerpack.encoder.java.extension.path" value="{'${powerpack.encoder.src.path}/java'}"/>
      <property name="powerpack.encoder.java.extension.classpath" value="${{encoder.java.extension.classpath}};${{powerpack.encoder.java.extension.path}};${{xerces-j.classpath}}"/>
      <property name="powerpack.encoder.generation.transform.path" value="{'${powerpack.encoder.src.path}/XsdToXsltEncoder.xsl'}"/>
      <property name="powerpack.b4j.encoder.transform.path" value="{'${powerpack.encoder.src.path}/B4jSimpleEncoder.xsl'}"/>
      <property name="powerpack.stacks.translation.transform.path" value="{'${powerpack.encoder.src.path}/ReplaceStacksInIsoB4J.xsl'}"/>
      
      <property name="powerpack.decoder.src.path" value="src/powerpack/decoder"/>
      <property name="powerpack.decoder.generation.transform.path" value="{'${powerpack.decoder.src.path}/XsdToJavaDecoder.xsl'}"/>
      <property name="powerpack.test.decoder.generation.transform.path" value="{'${powerpack.decoder.src.path}/XsdToJavaTestDecoder.xsl'}"/>
    </xsl:if>
    
    <xsl:comment> Xml Schemas </xsl:comment>
    <property name="xml.schema.path" value="src/schema"/>
    <property name="basic.schema.path" value="{'${xml.schema.path}/BasicXmlSchema.xsd'}"/>
    <property name="actions.in.basic.schema.path" value="{'${xml.schema.path}/BasicXmlSchemaPlusSemanticActions.xsd'}"/>
    
    <property name="user.schema.path" value="{'${USER.schema.dir.path}/${USER.schema.name}'}" />
    <property name="user.schema.backup.path" value="{'${user.schema.path}.bak'}" />
    <property name="user.schema.backup.before.removing.annotations.path" value="{'${user.schema.path}.before.removing.annotations.bak'}" />
    
    <xsl:comment> templates output files </xsl:comment>
    <property name="template.empty.schema.path" value="{'${xml.schema.path}/emptySchema.xsd'}"/>
    <property name="template.mathFP.schema.path" value="{'${xml.schema.path}/mathFP.xsd'}"/>
    <property name="template.include.idref.schema.path" value="{'${xml.schema.path}/idRefInclude.xsd'}"/>
    <property name="template.ignore.idref.schema.path" value="{'${xml.schema.path}/idRefIgnore.xsd'}"/>
    
    <xsl:comment> transformation sheets </xsl:comment>
    <property name="encoder.src.path" value="src/encoder"/>
    <property name="encoder.generation.transform.path" value="{'${encoder.src.path}/XsdToXsltEncoder.xsl'}"/>
    <property name="b4j.encoder.transform.path" value="{'${encoder.src.path}/B4jSimpleEncoder.xsl'}"/>
    
    <property name="decoder.src.path" value="src/decoder"/>
    <property name="decoder.generation.transform.path" value="{'${decoder.src.path}/XsdToJavaDecoder.xsl'}"/>
    <property name="test.decoder.generation.transform.path" value="{'${decoder.src.path}/XsdToJavaTestDecoder.xsl'}"/>
    <property name="java.transform.path" value="{'${decoder.src.path}/IsoJavaToJava.xsl'}"/>
    
    <property name="utils.src.path" value="src/utils"/>
    <property name="indent.transform.path" value="{'${utils.src.path}/xmlToIndent.xsl'}"/>
    <property name="indent.and.clean.schema.transform.path" value="{'${utils.src.path}/IndentAndRemoveNamespaceHelpers.xsl'}"/>
    <property name="pretty.print.transform.path" value="{'${pretty.print.path}/xmlverbatimwrapper.xsl'}"/>
    
    <property name="edit.src.path" value="src/edit"/>
    <property name="add.types.transform.path" value="{'${edit.src.path}/XsdAddMissingTypes.xsl'}"/>
    <property name="add.annotations.transform.path" value="{'${edit.src.path}/XsdAddAnnotations.xsl'}"/>
    <property name="remove.annotations.transform.path" value="{'${edit.src.path}/XsdRemoveAnnotations.xsl'}"/>
    
    <xsl:comment> encoding output files </xsl:comment>
    <property name="encoder.output.path" value="output/encoder"/>
    <property name="generated.encoder.transform.path" value="{'${encoder.output.path}/IsoB4jEncoder.xsl'}"/>
    <property name="generated.isob4j.path" value="{'${encoder.output.path}/${USER.output.data.name}.isob4j.xml'}"/>
    <property name="generated.b4j.name" value="{'${USER.output.data.name}.b4j'}"/>
    <property name="generated.b4j.path" value="{'${encoder.output.path}/${generated.b4j.name}'}"/>
    <property name="generated.empty.path" value="{'${encoder.output.path}/empty.txt'}"/>
    
    <xsl:comment> decoding output files </xsl:comment>
    <property name="decoder.output.path" value="output/decoder"/>  
    <property name="generated.decoder.isojava.path" value="{'${decoder.output.path}/B4JDecoder.isojava.xml'}"/>
    <property name="generated.decoder.path" value="{'${decoder.output.path}/B4JDecoder.java'}"/>
    
    <property name="generated.test.decoder.class.name" value="B4JTestDecoder"/>
    <property name="generated.test.decoder.src.name" value="{'${generated.test.decoder.class.name}.java'}"/>
    <property name="test.decoder.isojava.path" value="{'${decoder.output.path}/${generated.test.decoder.class.name}.isojava.xml'}"/>
    <property name="generated.test.decoder.src.path" value="{'${decoder.output.path}/${generated.test.decoder.src.name}'}"/>
    
    <property name="test.decoded.b4j.path" value="{'${decoder.output.path}/${generated.b4j.name}.decoded.xml'}"/>
    
    <xsl:comment> documentation output files </xsl:comment>
    <property name="doc.path" value="output/doc"/>
    <property name="schema.xhtml.doc.path" value="{'${doc.path}/userSchema.html'}"/>
  
    <xsl:comment> distrib </xsl:comment>
    <property name="distrib.dir.path" value="distrib" />
    
    <xsl:choose>
      <xsl:when test="$isPowerPackVersion">
        <property name="distrib.zip.name" value="b4j-with-powerpack.zip" />
        <property name="distrib.includes.pattern" value="build.xml encoder.version doc/** lib/** src/** usr/**" />
        <property name="distrib.excludes.pattern" value="**/draft **/draft/** **/material **/material/**" />
      </xsl:when>
      <xsl:otherwise>
        <property name="distrib.zip.name" value="b4j.zip" />
        <property name="distrib.includes.pattern" value="build.xml encoder.version doc/** lib/** src/** usr/**" />
        <property name="distrib.excludes.pattern" value="**/draft **/draft/** **/material **/material/** **/powerpack **/powerpack/**" />
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:comment> build number </xsl:comment>
    <property name="build.number.property.path" value="encoder.version" />
    
    <xsl:comment> Startup tasks </xsl:comment>
    
    <target name="description">
      <echo><xsl:call-template name="printB4JVersion" /></echo>
      <echo message="Available targets..." />
      <echo message="Startup:        createEmptySchema, addSchemaTypes, " />
      <echo message="                addSemanticActions, removeSemanticActions" />
      <echo message="Schema Backup:  saveSchema, loadSchema" />
      <echo message="Validation:     validateSchema, validateData" />
      <echo message="Encoding:       buildJavaExtension, generateEncoder, encoding" />
      <echo message="Decoding:       generateLocalDecoder, generateDecoder" />
      <echo message="Test Decoding:  generateTestDecoder, testDecoding" />
      <echo message="Documentation:  generatePrettyUserSchema" />
      <echo message="Distrib:        zipCode" />
    </target>
    
    <target name="init">
      <mkdir dir="${{distrib.dir.path}}" />
    </target>
    
    <target name="checkIfUserSchemaExists">
      <available property="schema.found.TRUE" file="{'${user.schema.path}'}" />
    </target>
    
    <target name="createEmptySchema" unless="schema.found.TRUE" depends="checkIfUserSchemaExists, createEmptySchemaElse">
      <echo message="Creating new schema..." />
      
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${ant.file}'}"/>
        <arg value="{'${template.empty.schema.path}'}"/>
      </java>
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${indent.and.clean.schema.transform.path}'}"/>
        <arg value="indentWithUnit=  "/>
      </java>
      
      <copy file="{'${template.fp.schema.path}'}" todir="{'${USER.schema.dir.path}'}" />
      <copy file="{'${template.include.idref.schema.path}'}" todir="{'${USER.schema.dir.path}'}" />
      <copy file="{'${template.ignore.idref.schema.path}'}" todir="{'${USER.schema.dir.path}'}" />
      <echo message="Done." />
    </target>
    <target name="createEmptySchemaElse" if="schema.found.TRUE" depends="checkIfUserSchemaExists">
      <echo message="User schema was found at: ${{user.schema.path}}" />
      <echo message="Nothing Done." />
    </target>
    
    <target name="addSchemaTypes">
      <echo message="Adding missing Complex and Simple Types in User Schema..." />
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${add.types.transform.path}'}"/>
      </java>
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${indent.transform.path}'}"/>
        <arg value="indentWithUnit=  "/>
      </java>
      <echo message="Done." />
    </target>
    
    <target name="addSemanticActions">
      <echo message="Adding empty Semantic Actions in User Schema..." />
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${add.annotations.transform.path}'}"/>
      </java>
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${indent.transform.path}'}"/>
        <arg value="indentWithUnit=  "/>
      </java>
      <echo message="Done." />
    </target>
    
    <target name="removeSemanticActions">
      <echo message="Removing All Semantic Actions from User Schema..." />
      <echo message="(Original Schema is saved to {'${user.schema.backup.before.removing.annotations.path}'})..." />
      <copy file="{'${user.schema.path}'}" tofile="{'${user.schema.backup.before.removing.annotations.path}'}" overwrite="true"/>
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${remove.annotations.transform.path}'}"/>
      </java>
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${user.schema.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${indent.transform.path}'}"/>
        <arg value="indentWithUnit=  "/>
      </java>
      <echo message="Done." />
    </target>
    
    <xsl:comment> Backup Tasks </xsl:comment>
    <target name="saveSchema">
      <echo message="Saving User Schema to {'${user.schema.backup.path}'}..." />
      <copy file="{'${user.schema.path}'}" tofile="{'${user.schema.backup.path}'}" overwrite="true"/>
      <echo message="Done." />
    </target>
    
    <target name="loadSchema">
      <echo message="Loading Saved User Schema from {'${user.schema.backup.path}'}..." />
      <copy file="{'${user.schema.backup.path}'}" tofile="{'${user.schema.path}'}" overwrite="true"/>
      <echo message="Done." />
    </target>
    
    <xsl:comment> Validation Tasks </xsl:comment>
    
    <target name="validateSchema">
      <echo message="Validating User Defined Xml Schema against Basic Xml Schema..." />
      <antcall target="validateDataUsingSunMSV"> <xsl:comment> better error messages </xsl:comment>
      <xsl:comment> &lt;antcall target="validateDataUsingJing"&gt; is more accurate </xsl:comment>
        <param name="param.xml.data" value="{'${user.schema.path}'}"/>
        <param name="param.xml.schema" value="{'${actions.in.basic.schema.path}'}"/>
      </antcall>
      <echo message="Validating User Defined Xml Schema against Standard Xml Schema..." />
      <antcall target="validateSchemaUsingJing">
        <param name="param.xml.schema" value="{'${user.schema.path}'}"/>
      </antcall>
      <echo message="Done." />
    </target>
    
    <target name="validateData">
      <echo message="Validating User Defined Data against User Defined Xml Schema..." />
      <antcall target="validateDataUsingJing">
        <param name="param.xml.data" value="{'${USER.input.data.path}'}"/>
        <param name="param.xml.schema" value="{'${user.schema.path}'}"/>
      </antcall>
      <echo message="Done." />
    </target>
    
    
    <xsl:comment> Encoding Tasks </xsl:comment>
    
    <target name="getNewVersionNumber" if="USER.include.version.number.TRUE" depends="VersionNumberDisabled">
      <buildnumber file="{'${build.number.property.path}'}"/>
      <property name="version.number" value="{'${build.number}'}" />
    </target>
    <target name="VersionNumberDisabled" unless="USER.include.version.number.TRUE">
      <property name="version.number" value="DISABLED" />
    </target>
    
    <target name="getVersionNumber" if="version.number" depends="VersionNumberMissing"/>
    <target name="VersionNumberMissing" unless="version.number">
      <property name="version.number" value="DISABLED" />
    </target>
    
    <target name="generateEncoder" depends="validateSchema, getNewVersionNumber">
      <xsl:choose>
        <xsl:when test="$isPowerPackVersion">
          <echo message="[Using PowerPack] Generating Binary 4 Java Encoder (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.encoder.transform.path}'}"/>
            <arg value="{'${user.schema.path}'}"/>
            <arg value="{'${powerpack.encoder.generation.transform.path}'}"/>
            <arg value="formatVersion={'${version.number}'}"/>
          </java>
        </xsl:when>  
        <xsl:otherwise>
          <echo message="Generating Binary 4 Java Encoder (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.encoder.transform.path}'}"/>
            <arg value="{'${user.schema.path}'}"/>
            <arg value="{'${encoder.generation.transform.path}'}"/>
            <arg value="formatVersion={'${version.number}'}"/>
          </java>
        </xsl:otherwise>
      </xsl:choose>
      <echo message="Done." />
    </target>
    
    
    <target name="buildJavaExtension">
      <xsl:choose>
        <xsl:when test="$isPowerPackVersion">
          <echo message="[Using PowerPack] Building Java Extension Class for Encoding through XSLT..." />
          <javac srcdir="${{encoder.java.extension.path}}" classpath="${{encoder.java.extension.classpath}}"/>
          <javac srcdir="${{powerpack.encoder.java.extension.path}}" classpath="${{powerpack.encoder.java.extension.classpath}}"/>
        </xsl:when>
        <xsl:otherwise>
          <echo message="Building Java Extension Class for Encoding through XSLT..." />
          <javac srcdir="${{encoder.java.extension.path}}" classpath="${{encoder.java.extension.classpath}}"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <echo message="Done." />
    </target>
    
    
    
    
    <target name="encoding" depends="generateEncoder, buildJavaExtension, validateData, getVersionNumber">
      <xsl:choose>
        <xsl:when test="$isPowerPackVersion">
          <echo message="[Using PowerPack] Encoding Binary for Java file from Input XML (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.isob4j.path}'}.stk"/>
            <arg value="{'${USER.input.data.path}'}"/>
            <arg value="{'${generated.encoder.transform.path}'}"/>
          </java>
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.isob4j.path}'}"/>
            <arg value="{'${generated.isob4j.path}'}.stk"/>
            <arg value="{'${powerpack.stacks.translation.transform.path}'}"/>
          </java>
          <delete file="{'${generated.isob4j.path}'}.stk" />
          
          <java classname="{'${xalan.class}'}" classpath="{'${encoder.java.extension.path}'};{'${powerpack.encoder.java.extension.path}'}" fork="true">
            <arg value="-IN"/><arg value="{'${generated.isob4j.path}'}"/>
            <arg value="-XSL"/><arg value="{'${powerpack.b4j.encoder.transform.path}'}"/>
            <arg value="-PARAM"/><arg value="b4jFileName"/><arg value="{'${generated.b4j.path}'}"/>
            <arg value="-OUT"/><arg value="{'${generated.empty.path}'}"/>
          </java>
          <delete file="{'${generated.empty.path}'}" />
          <copy file="{'${generated.b4j.path}'}" todir="{'${USER.output.data.dir.path}'}" />
        </xsl:when>
        <xsl:otherwise>
          <echo message="Encoding Binary for Java file from Input XML (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.isob4j.path}'}"/>
            <arg value="{'${USER.input.data.path}'}"/>
            <arg value="{'${generated.encoder.transform.path}'}"/>
          </java>
          
          <java classname="{'${xalan.class}'}" classpath="{'${encoder.java.extension.path}'}" fork="true">
            <arg value="-IN"/><arg value="{'${generated.isob4j.path}'}"/>
            <arg value="-XSL"/><arg value="{'${b4j.encoder.transform.path}'}"/>
            <arg value="-PARAM"/><arg value="b4jFileName"/><arg value="{'${generated.b4j.path}'}"/>
            <arg value="-OUT"/><arg value="{'${generated.empty.path}'}"/>
          </java>
          <delete file="{'${generated.empty.path}'}" />
          <copy file="{'${generated.b4j.path}'}" todir="{'${USER.output.data.dir.path}'}" />
        </xsl:otherwise>
      </xsl:choose>
      
      <echo message="Done." />
    </target>
    
    
    <xsl:comment> Decoding Tasks </xsl:comment>
    
    <target name="generateLocalDecoder" depends="validateSchema, encoding, getVersionNumber">
      <xsl:choose>
        <xsl:when test="$isPowerPackVersion">
          <echo message="[Using PowerPack] Generating Java Decoder Locally (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.decoder.isojava.path}'}"/>
            <arg value="{'${user.schema.path}'}"/>
            <arg value="{'${powerpack.decoder.generation.transform.path}'}"/>
            <arg value="formatVersion={'${version.number}'}"/>
            <arg value="packageName={'${USER.decoder.java.package}'}"/>
          </java>
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.decoder.path}'}"/>
            <arg value="{'${generated.decoder.isojava.path}'}"/>
            <arg value="{'${java.transform.path}'}"/>
          </java>
          <antcall target="indentJavaUsingArtisticStyle">
            <param name="java.file.to.indent" value="{'${generated.decoder.path}'}"/>
          </antcall>
        </xsl:when>
        <xsl:otherwise>
          <echo message="Generating Java Decoder Locally (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.decoder.isojava.path}'}"/>
            <arg value="{'${user.schema.path}'}"/>
            <arg value="{'${decoder.generation.transform.path}'}"/>
            <arg value="formatVersion={'${version.number}'}"/>
            <arg value="packageName={'${USER.decoder.java.package}'}"/>
          </java>
          
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.decoder.path}'}"/>
            <arg value="{'${generated.decoder.isojava.path}'}"/>
            <arg value="{'${java.transform.path}'}"/>
          </java>
          
          <antcall target="indentJavaUsingArtisticStyle">
            <param name="java.file.to.indent" value="{'${generated.decoder.path}'}"/>
          </antcall>
        </xsl:otherwise>
      </xsl:choose>
      
      <echo message="Done." />
    </target>
    
    <target name="generateDecoder" depends="generateLocalDecoder">
      <echo message="Copying Generated Java Decoder to External Project..." />
      <copy file="{'${generated.decoder.path}'}" todir="{'${USER.java.package.dir.path}'}" />
      <echo message="Done." />
    </target>
    
    <xsl:comment> Test Decoding Tasks </xsl:comment>
    
    <target name="generateTestDecoder" depends="validateSchema, encoding, getVersionNumber">
      <xsl:choose>
        <xsl:when test="$isPowerPackVersion">
          <echo message="[Using PowerPack] Generating Java Test Decoder (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${test.decoder.isojava.path}'}"/>
            <arg value="{'${user.schema.path}'}"/>
            <arg value="{'${powerpack.test.decoder.generation.transform.path}'}"/>
            <arg value="formatVersion={'${version.number}'}"/>
          </java>
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.test.decoder.src.path}'}"/>
            <arg value="{'${test.decoder.isojava.path}'}"/>
            <arg value="{'${java.transform.path}'}"/>
          </java>
          <antcall target="indentJavaUsingArtisticStyle">
            <param name="java.file.to.indent" value="{'${generated.test.decoder.src.path}'}"/>
          </antcall>
          <javac srcdir="{'${decoder.output.path}'}" includes="{'${generated.test.decoder.src.name}'}" />
        </xsl:when>
        <xsl:otherwise>
          <echo message="Generating Java Test Decoder (v. {'${version.number}'})..." />
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${test.decoder.isojava.path}'}"/>
            <arg value="{'${user.schema.path}'}"/>
            <arg value="{'${test.decoder.generation.transform.path}'}"/>
            <arg value="formatVersion={'${version.number}'}"/>
          </java>
          <java jar="{'${saxon.jar}'}" fork="true">
            <arg value="-o"/><arg value="{'${generated.test.decoder.src.path}'}"/>
            <arg value="{'${test.decoder.isojava.path}'}"/>
            <arg value="{'${java.transform.path}'}"/>
          </java>
          <antcall target="indentJavaUsingArtisticStyle">
            <param name="java.file.to.indent" value="{'${generated.test.decoder.src.path}'}"/>
          </antcall>
          <javac srcdir="{'${decoder.output.path}'}" includes="{'${generated.test.decoder.src.name}'}" />
        </xsl:otherwise>
      </xsl:choose>
      
      <echo message="Done." />
    </target>
    
    
    <target name="testDecoding" depends="generateTestDecoder">
      <echo message="Decoding Binary for Java file (v. {'${version.number}'})..." />
      <java classname="{'${generated.test.decoder.class.name}'}" classpath="{'${decoder.output.path}'}" fork="true">
        <arg value="{'${generated.b4j.path}'}"/>
        <arg value="{'${test.decoded.b4j.path}'}.noindent"/>
      </java>
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${test.decoded.b4j.path}'}"/>
        <arg value="{'${test.decoded.b4j.path}'}.noindent"/>
        <arg value="{'${indent.transform.path}'}"/>
      </java>
      <delete file="{'${test.decoded.b4j.path}'}.noindent" />
      <echo message="Done." />
    </target>
    
    <xsl:comment> documentation tasks </xsl:comment>
    <target name="copyPrettyPrintCSS">
      <copy file="{'${pretty.print.css.path}'}" todir="{'${doc.path}'}" />
    </target>
    
    <target name="generatePrettyUserSchema" depends="copyPrettyPrintCSS">
      <echo message="Generating XHTML page for User Xml Schema..." />
      <java jar="{'${saxon.jar}'}" fork="true">
        <arg value="-o"/><arg value="{'${schema.xhtml.doc.path}'}"/>
        <arg value="{'${user.schema.path}'}"/>
        <arg value="{'${pretty.print.transform.path}'}"/>
      </java>
      <echo message="Done." />
    </target>
    
    <xsl:comment> distrib </xsl:comment>
    <target name="zipCode" depends="init">
      <tstamp>
        <format property="std-date-today" pattern="yyyy-MM-dd" locale="en"/>
      </tstamp>
      <zip destfile="{'${distrib.dir.path}'}\{'${std-date-today}'}-{'${distrib.zip.name}'}" update="no">
        <zipfileset dir="." includes="{'${distrib.includes.pattern}'}" excludes="{'${distrib.excludes.pattern}'}" prefix="b4j"/>
      </zip>
    </target>
    
  </project>
</xsl:template>

<xsl:template name="printB4JVersion">
  <xsl:choose>
    <xsl:when test="$isPowerPackVersion = true()"> 
      <xsl:value-of select="concat('B4J ',$b4j-version-number,' POWER PACK Version')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('B4J ',$b4j-version-number,' STANDARD Version')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="newLine">
  <xsl:text>
</xsl:text>
</xsl:template>
  
</xsl:stylesheet>