package name.brechemier.eric;

import java.io.FileOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;

import com.beartronics.FP; // for float/double conversions to int

/**
 * Used by XSLT transforms to create a binary document with values
 * easy to decode in a Java application (or binary for java file). <br />
 * 
 * As there are no floating points on the target mobile phone device,
 * we encode floats as equivalent integers using Beartronics Fixed Point Library. <br />
 * 
 * Version 1.0: created on July 20th, 2004    <br />
 * Version 1.1: created on October 26th, 2004 <br />
 * Version 1.2: created on January 19th, 2005 <br />
 *
 * @author Eric Bréchemier
 * @version 1.2
 */
public class JavaEncoder
{
   public static void testUsage()
   {
      try
      {
         openBinaryOutput("testUsage.b4j");
         
         writeInt(1);
         
         closeBinaryOutput();
      }
      catch(IOException e)
      {
         e.printStackTrace();
      }
   }
   
   
   // 360° = 2PI (rad)
   //   1° = PI/180 (rad)
   protected static final int FP_DEG_TO_RAD_FACTOR = FP.Div(FP.PI, FP.intToFP(180));
   
   protected DataOutputStream output;
   
   protected static JavaEncoder _singleton = new JavaEncoder();
   
   public static void openBinaryOutput(String fileName) throws IOException
   {
      _singleton.output = new DataOutputStream(new FileOutputStream(fileName));
   }
   
   public static DataOutputStream getOutputFile() {
     if (_singleton!=null)
     {
       return _singleton.output;
     }
     else 
     {
       return null;
     }
   }
   
   public static void closeBinaryOutput() throws IOException
   {
      _singleton.output.close();
   }
   
   public static void writeBoolean(boolean data) throws IOException
   {
      _singleton.output.writeBoolean(data);
   }
   
   public static void writeByte(byte data) throws IOException
   {
      _singleton.output.writeByte(data);
   }
   
   public static void writeMaskByte(byte bit1, byte bit2, byte bit3, byte bit4, byte bit5, byte bit6, byte bit7, byte bit8) throws IOException
   {
      byte data = (byte)((bit1&1)|((bit2&1)<<1)|((bit3&1)<<2)|((bit4&1)<<3)|((bit5&1)<<4)|((bit6&1)<<5)|((bit7&1)<<6)|((bit8&1)<<7));
      _singleton.output.writeByte(data);
   }
   
   public static void writeShort(short data) throws IOException
   {
      _singleton.output.writeShort(data);
   }
   
   public static void writeInt(int data) throws IOException
   {
      _singleton.output.writeInt(data);
   }
   
   public static void writeAlphaColor(long data) throws IOException
   {
      writeUnsignedIntFromLong(data);
   }
   
   public static void writeUnsignedIntFromLong(long longData) throws IOException
   {
      int intData = (int)(longData & 0xFFFFFFFFL );
      _singleton.output.writeInt(intData);
   }
   
   public static void writeLong(long data) throws IOException
   {
      _singleton.output.writeLong(data);
   }
   
   protected static int stringToFP(String floatNumber)
   {
     int comaPos = floatNumber.indexOf('.');
     
     int iPart;
     int fPartAsInt = 0;
     int fPartCoeff = 1;
     
     if (comaPos!=-1) 
     {
       iPart = Integer.parseInt( floatNumber.substring(0,comaPos) );
       
         //      comaPos=5  lastPos=9
         // 01234.6789 floatPartLength=4
       int lastPos = floatNumber.length()-1;
       int floatPartLength = lastPos - comaPos;
       
       if (floatPartLength > 0) 
       {
         fPartAsInt = Integer.parseInt( floatNumber.substring(comaPos+1) );
         
         for (int i=0; i<floatPartLength; i++) {
           fPartCoeff *= 10;
         }
       }
     }
     else
     {
       iPart = Integer.parseInt( floatNumber );
     }
     
     int fpIPart = FP.intToFP(iPart);
     int fpFPart = FP.intToFP(fPartAsInt)/fPartCoeff;
     
     int fpValue = fpIPart + fpFPart;
     return fpValue;
   }
   
   protected static int fpConvertAngleDegToRad( int fpDegAngle )
   {
      return FP.Mul(FP_DEG_TO_RAD_FACTOR,fpDegAngle);
   }
   
   public static void writeRadAngleString(String floatDegAngle) throws IOException
   {
      int fpRadAngle = fpConvertAngleDegToRad( stringToFP(floatDegAngle) );
      _singleton.output.writeInt( fpRadAngle );
   }
   
   public static void writeCosAngleString(String floatDegAngle) throws IOException
   {
      int fpRadAngle = fpConvertAngleDegToRad( stringToFP(floatDegAngle) );
      _singleton.output.writeInt( FP.Cos(fpRadAngle) );
   }
   
   public static void writeSinAngleString(String floatDegAngle) throws IOException
   {
      int fpRadAngle = fpConvertAngleDegToRad( stringToFP(floatDegAngle) );
      _singleton.output.writeInt( FP.Sin(fpRadAngle) );
   }
   
   public static void writeMinusCosAngleString(String floatDegAngle) throws IOException
   {
      int fpRadAngle = fpConvertAngleDegToRad( stringToFP(floatDegAngle) );
      int fpCosAngle = FP.Cos(fpRadAngle);
      _singleton.output.writeInt( FP.Mul(fpCosAngle, -FP.ONE )  );
   }
   
   public static void writeMinusSinAngleString(String floatDegAngle) throws IOException
   {
      int fpRadAngle = fpConvertAngleDegToRad( stringToFP(floatDegAngle) );
      int fpSinAngle = FP.Sin(fpRadAngle);
      _singleton.output.writeInt( FP.Mul(fpSinAngle, -FP.ONE )  );
   }
   
   
   
   public static void writeFloatString(String floatData) throws IOException
   {
      _singleton.output.writeInt( stringToFP(floatData) );
   }
   
   public static void writeFloat(float data) throws IOException
   {
      // encoding with FPLib
      writeFloatString( Float.toString(data) );
   }
   
   public static void writeDouble(double data) throws IOException
   {
      // encoding with FPLib
      writeFloatString( Double.toString(data) );
   }
   
   public static void writeStringUTF(String data) throws IOException
   {
      _singleton.output.writeUTF(data);
   }
}