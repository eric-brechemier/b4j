package name.brechemier.eric;

import java.io.FileInputStream;
import java.io.IOException;


/*
import java.io.FileOutputStream;
import java.io.DataOutputStream;

*/

/**
 * <b>(PowerPack version)</b><br />
 * Used by XSLT transforms to create a binary document with values
 * easy to decode in a Java application (or binary for java file). <br />
 * 
 * Version 1.0: created on November 17th, 2004    <br />
 *
 * @author Eric Bréchemier
 * @version 1.0
 */
public class PowerPackJavaEncoder
{
   public static void writeFile(String fileName) throws IOException
   {
      FileInputStream file = new FileInputStream(fileName);
      int dataLength = file.available();
      byte[] fileData = new byte[dataLength];
      file.read(fileData);
      
      JavaEncoder.getOutputFile().writeInt(dataLength);
      JavaEncoder.getOutputFile().write(fileData,0,fileData.length);
   }
}