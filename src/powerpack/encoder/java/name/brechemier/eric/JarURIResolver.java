package name.brechemier.eric;

import java.io.InputStream;

import javax.xml.transform.Source;
import javax.xml.transform.URIResolver;
import javax.xml.transform.TransformerException;

import javax.xml.transform.sax.SAXSource;

import org.xml.sax.InputSource;


/**
 * Jar URI Resolver: <br/>
 * Creates SAXSource from jar files.
 *
 * @author Eric Bréchemier
 * @version 1.0
 */
public class JarURIResolver implements URIResolver {
  
  public Source resolve(String href, String base) throws TransformerException {
  
    try {
      
      String path = resolvePath(href,base);
      
      InputStream jarSource = getClass().getResourceAsStream(path);
      SAXSource source = new SAXSource( new InputSource(jarSource) );
      return source;
      
    } catch(Exception e) {
      throw new TransformerException("JarURIResolver: "+e);
    }
    
  }
  
  // NOTA BENE set Source system Id using jar:// locator to avoid conversion to file:///C:/myPath
  // e.g. stackTransformSource.setSystemId("jar:///xslt/powerpack/encoder/");
  public static String resolvePath (String href, String base) throws Exception {
    
    if (base==null) {
      System.err.println("JarURIResolver.resolvePath> ERROR href="+href+" base="+base);
      throw new Exception("JarURIResolver: missing system Id for base. href="+href+" base="+base);
    }
    
    if (base.startsWith("file:///") ) {
      System.err.println("JarURIResolver.resolvePath> ERROR href="+href+" base="+base);
      System.err.println("  Please set Source system Id using jar:// locator to avoid conversion to file:///C:/myPath");
      throw new Exception("JarURIResolver: wrong system Id for base. href="+href+" base="+base);
    }
    
    if (href==null) {
      System.err.println("JarURIResolver.resolvePath> ERROR href="+href+" base="+base);
      throw new Exception("JarURIResolver: incorrect href. href="+href+" base="+base);
    }
    
    if ( base.endsWith("/") ) {
      String baseWithoutFinalSlash = substringBefore(base,"/");
      return resolvePath(href,baseWithoutFinalSlash);
    }
    
    if ( base.startsWith("jar://") ) {
      String baseWithoutLocator = substringAfter(base,"jar://");
      return resolvePath(href,baseWithoutLocator);
    }
    
    if ( !base.startsWith("/") ) {
      return resolvePath(href,"/"+base);
    }
    
    if ( href.startsWith("../") ) 
    {
      String parentBase = substringBefore(base,"/");
      String hrefParentRelative = substringAfter(href,"../");
      return resolvePath(hrefParentRelative,parentBase);
    } 
    
    if ( href.startsWith("./") ) 
    {
      String hrefParentRelative = substringAfter(href,"./");
      return resolvePath(hrefParentRelative,base);
    }
    
    return base+"/"+href;
  }
  
  public static String substringAfter(String source, String prefix) {
    
    final int PREFIX_NOT_FOUND = -1;
    
    int prefixStart = source.indexOf(prefix);
    if (prefixStart==PREFIX_NOT_FOUND)
      return "";
    
    int substringStart = prefixStart+prefix.length();
    if (substringStart >= source.length() )
      return "";
      
    return source.substring(substringStart);
  }
  
  public static String substringBefore(String source, String suffix) {
    
    final int SUFFIX_NOT_FOUND = -1;
    
    int suffixStart = source.lastIndexOf(suffix);
    if (suffixStart==SUFFIX_NOT_FOUND)
      return source;
    
    int substringEndExclusive = suffixStart;
    return source.substring(0,substringEndExclusive);
  }
  
}