package name.brechemier.eric;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import javax.xml.transform.TransformerFactory;

import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;

import javax.xml.transform.stream.StreamSource;

import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.Serializer;
import org.apache.xml.serialize.SerializerFactory;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

/**
 * Power Pack B4J Encoder Wrapper: <br/>
 * Wrapper Class for User Generated Specific Encoder.
 *
 * @author Eric Bréchemier
 * @version 1.0
 */
public class PowerPackB4JEncoderWrapper {
  
  public static void main(String[] args) {
    
    if (args.length!=2) {
      System.out.println("Usage: xmlInputFile b4jOutputFile");
      System.out.println("  xmlInputFile  -- path to xml input file, valid according to user XML Schema");
      System.out.println("  b4jOutputFile -- path to b4j output file, resulting from encoding");
      return;
    }
    
    String xmlInputFilePath = args[0];
    String b4jOutputFilePath = args[1];
    
    FileInputStream xmlInputFile = null;
    FileOutputStream b4jOutputFile = null;
    
    try {
      
      log("PowerPackB4JEncoderWrapper","main","Creating Encoder",LOG_INFO);
      PowerPackB4JEncoderWrapper b4jEncoder = new PowerPackB4JEncoderWrapper();
      log("PowerPackB4JEncoderWrapper","main","Encoder Created",LOG_INFO);
      
      xmlInputFile = new FileInputStream(xmlInputFilePath);
      b4jOutputFile = new FileOutputStream(b4jOutputFilePath);
      
      InputStream in = b4jEncoder.b4jEncode(xmlInputFile);
      log("PowerPackB4JEncoderWrapper","main","Serializing Result",LOG_INFO);
      convertInputToOutput(in,b4jOutputFile);
      log("PowerPackB4JEncoderWrapper","main","Result Serialized",LOG_INFO);
      
      try { in.close(); } catch(Exception e) {}
    
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
    finally {
      try { xmlInputFile.close(); } catch(Exception e) {}
      try { b4jOutputFile.close(); } catch(Exception e) {}
    }
    
  }
  
  public static final int LOG_ALL = -10;
  public static final int LOG_EXTRA_DETAIL = -2;
  public static final int LOG_DETAIL = -1;
  public static final int LOG_INFO = 0;
  public static final int LOG_WARNING = 1;
  public static final int LOG_CRITICAL = 2;
  public static final int LOG_ERROR = 3;
  public static final int LOG_NONE = 10;
  
  private static final int logLevel = LOG_ALL;
  
  public static final void log(String className, String methodName, String messageText, int messageLevel) {
    
    if (messageLevel > logLevel)
      System.out.println(className+"."+methodName+"> "+messageText);
  }
  
  
  public static void convertInputToOutput(InputStream in, OutputStream out) throws IOException {
    
    while ( in.available()>0 ) {
      int bytesToRead = in.available();
      byte [] buffer = new byte[bytesToRead];
      in.read(buffer);
      out.write(buffer);
    }
    
  }
  
  
  
  private TransformerHandler specificTransform;
  private TransformerHandler stackTransform;
  private TransformerHandler binaryb4jTransform;
  
  private XMLReader reader;
  
  private SAXTransformerFactory getSAXTransformerFactory() throws Exception {
    
    TransformerFactory tFactory = TransformerFactory.newInstance();
    if (!tFactory.getFeature(SAXSource.FEATURE) || !tFactory.getFeature(SAXResult.FEATURE))
    {
      System.err.println("PowerPackB4JEncoderWrapper.getSAXTransformerFactory> "+tFactory+" is not a SAXTransformerFactory");
      System.err.println("PowerPackB4JEncoderWrapper.getSAXTransformerFactory> SAXSource.support:"+tFactory.getFeature(SAXSource.FEATURE)+" SAXResult.support:"+tFactory.getFeature(SAXResult.FEATURE));
      throw new Exception("SAXTransformerFactory not supported");
    }
    
    return ((SAXTransformerFactory) tFactory);
  }
  
  private static final String TEMP_B4J_FILE = "output/test/temp.b4j";
  
  public PowerPackB4JEncoderWrapper() {
    
    
    try {
      
      log("PowerPackB4JEncoderWrapper","new","Creating Transform Factory",LOG_INFO);
      SAXTransformerFactory transformFactory = getSAXTransformerFactory();
      transformFactory.setURIResolver(new JarURIResolver());
      log("PowerPackB4JEncoderWrapper","new","Transform Factory Created",LOG_INFO);
      
      log("PowerPackB4JEncoderWrapper","new","Creating Specific Transform",LOG_INFO);
      InputStream xslSpecific = getClass().getResourceAsStream("/xslt/IsoB4jEncoder.xsl");
      StreamSource specificTransformSource = new StreamSource(xslSpecific);
      specificTransformSource.setSystemId("jar:///xslt/");
      specificTransform = transformFactory.newTransformerHandler(specificTransformSource);
      log("PowerPackB4JEncoderWrapper","new","Specific Transform Created",LOG_INFO);
      
      log("PowerPackB4JEncoderWrapper","new","Creating Stacks Conversion Transform",LOG_INFO);
      InputStream xslStack = getClass().getResourceAsStream("/xslt/powerpack/encoder/ReplaceStacksInIsoB4J.xsl");
      StreamSource stackTransformSource = new StreamSource(xslStack);
      stackTransformSource.setSystemId("jar:///xslt/powerpack/encoder/");
      stackTransform = transformFactory.newTransformerHandler(stackTransformSource);
      log("PowerPackB4JEncoderWrapper","new","Stacks Conversion Transform Created",LOG_INFO);
      
      log("PowerPackB4JEncoderWrapper","new","Creating Simple Encoder Transform",LOG_INFO);
      InputStream xslBinaryB4J = getClass().getResourceAsStream("/xslt/powerpack/encoder/B4jSimpleEncoder.xsl");
      log("PowerPackB4JEncoderWrapper","new","step 1",LOG_INFO);
      StreamSource binaryb4jTransformSource = new StreamSource(xslBinaryB4J);
      log("PowerPackB4JEncoderWrapper","new","step 2",LOG_INFO);
      binaryb4jTransformSource.setSystemId("jar:///xslt/powerpack/encoder/");
      log("PowerPackB4JEncoderWrapper","new","step 3",LOG_INFO);
      binaryb4jTransform = transformFactory.newTransformerHandler(binaryb4jTransformSource);
      log("PowerPackB4JEncoderWrapper","new","step 4",LOG_INFO);
      binaryb4jTransform.getTransformer().setParameter("b4jFileName",TEMP_B4J_FILE);
      log("PowerPackB4JEncoderWrapper","new","step 5",LOG_INFO);
      /*
      InputStream xslBinaryB4J = getClass().getResourceAsStream("/xslt/powerpack/encoder/B4jSimpleEncoder.xsl");
      StreamSource binaryb4jTransformSource = new StreamSource(xslBinaryB4J);
      binaryb4jTransformSource.setSystemId("jar:///xslt/powerpack/encoder/");
      binaryb4jTransform = transformFactory.newTransformerHandler(binaryb4jTransformSource);
      binaryb4jTransform.getTransformer().setParameter("b4jFileName",TEMP_B4J_FILE);
      */
      log("PowerPackB4JEncoderWrapper","new","Simple Encoder Transform Created",LOG_INFO);
      
      log("PowerPackB4JEncoderWrapper","new","Chaining Transforms",LOG_INFO);
      TransformerHandler tHandler1 = specificTransform;
      TransformerHandler tHandler2 = stackTransform;
      TransformerHandler tHandler3 = binaryb4jTransform;
      
      reader = XMLReaderFactory.createXMLReader();
      reader.setContentHandler(tHandler1);
      reader.setProperty("http://xml.org/sax/properties/lexical-handler", tHandler1);
      
      tHandler1.setResult(new SAXResult(tHandler2));
      /*
      tHandler2.setResult(new SAXResult(tHandler3));
      
      SerializerFactory serializerFactory = SerializerFactory.getSerializerFactory("xml");
      Serializer serializer 
        = serializerFactory.makeSerializer(System.out, new OutputFormat("xml","ISO-8859-1",true));
      
      tHandler3.setResult(new SAXResult(serializer.asContentHandler()));
      */
      
      // DEBUG
      SerializerFactory serializerFactory = SerializerFactory.getSerializerFactory("xml");
      Serializer serializer 
        = serializerFactory.makeSerializer(System.out, new OutputFormat("xml","ISO-8859-1",true));
      tHandler2.setResult(new SAXResult(serializer.asContentHandler()));
      // DEBUG
      
      log("PowerPackB4JEncoderWrapper","new","Transforms Chained",LOG_INFO);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    
  }
  
  public InputStream b4jEncode(InputStream xmlData) {
    
    try {
      
      // TODO: set DataOutputStream in extension
      reader.parse(new InputSource(xmlData));
      // TODO: get DataOutputStream from extension
      return new FileInputStream(TEMP_B4J_FILE);
      
    } catch(Exception e) {
      e.printStackTrace();
      return null;
    }
      
  }
  
}