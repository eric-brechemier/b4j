/* PLEASE DO NOT EDIT THIS FILE, it was generated by an XSLT Transformation */

package com.example;

import java.io.DataInputStream;
import java.io.IOException;

// Java imports
import java.io.FileInputStream;
import java.io.FileNotFoundException;

/**
 * Binary for Java (.b4j) file Decoder 
 * Intended use in Java J2ME MIDlets.
 * @author Generated by an XSLT transformation sheet (c) 2004 Eric Br�chemier, ExpWay, Pastagames
 * @version 1.0
 */
public class B4JDecoder {


    static byte firstCategoryCount = 0;
    static byte secondCategoryCount = 0;
    static byte thirdCategoryCount = 0;

    static byte teamScore = 0;

    public static void main(String[] args) {
        DataInputStream data = null;
        try {
            data = new DataInputStream( new FileInputStream("gameData.b4j") );
        } catch (FileNotFoundException e) {
            System.out.println("gameData.b4j was not found.");
        }

        decodeDocument(data);
    }


    public static void decodeDocument( DataInputStream data ) {

        try {

            System.out.println("Bienvenue dans Guess Me Right!");
            decodeQuizz(data);

            System.out.println("Votre score est :"+teamScore);
            System.out.println("Merci d'avoir jou�!");
        } catch(Exception e) {
            System.out.println("Decoding failed: " + e);
        } finally {}

    }

    private static void decodeQuizz( DataInputStream data ) throws IOException {


        // User Java Code
        byte presenceMaskFromTopic = data.readByte();
        boolean isAtTopicPresent = (  ( presenceMaskFromTopic&0x1 )!=0  );
        String atTopic = null;
        if ( isAtTopicPresent ) {
            atTopic = data.readUTF();
        }

        // User Java Code
        // e.g. if (isAtIdPresent) {
        //        currentElement = new ElementType(atId);
        //      } else {
        //        currentElement = new ElementType();
        //      }
        short __sequenceCount1 = data.readShort();
        short __sequenceCount2 = data.readShort();
        short childCount = (short)( __sequenceCount1 + __sequenceCount2 );

        // User Java Code
        // e.g. ChildType[] children = new ChildType[childCount];
        //      currentElement.setChildren(children);
        {
            for (short __i=0; __i<__sequenceCount1; __i++) {
                decodeQuestions(data);
            }
            for (short __i=0; __i<__sequenceCount2; __i++) {
                decodeResult(data);
            }
        }

        // User Java Code

    }

    private static void decodeQuestions( DataInputStream data ) throws IOException {


        // User Java Code
        short __sequenceCount1 = data.readShort();
        short childCount = (short)( __sequenceCount1 );

        // User Java Code
        // e.g. ChildType[] children = new ChildType[childCount];
        //      currentElement.setChildren(children);
        {
            for (short __i=0; __i<__sequenceCount1; __i++) {
                decodeQuestion(data);
            }
        }

        // User Java Code

    }

    private static void decodeResult( DataInputStream data ) throws IOException {


        // User Java Code
        short __sequenceCount1 = data.readShort();
        short childCount = (short)( __sequenceCount1 );

        // User Java Code
        // e.g. ChildType[] children = new ChildType[childCount];
        //      currentElement.setChildren(children);
        {
            for (short __i=0; __i<__sequenceCount1; __i++) {
                decodeCategory(data);
            }
        }

        // User Java Code

    }

    private static void decodeQuestion( DataInputStream data ) throws IOException {


        // User Java Code
        byte presenceMaskFromTitle = data.readByte();
        boolean isAtTitlePresent = (  ( presenceMaskFromTitle&0x1 )!=0  );
        String atTitle = null;
        if ( isAtTitlePresent ) {
            atTitle = data.readUTF();
        }

        // User Java Code
        // e.g. if (isAtIdPresent) {
        //        currentElement = new ElementType(atId);
        //      } else {
        //        currentElement = new ElementType();
        //      }
        short __sequenceCount1 = data.readShort();
        short __sequenceCount2 = data.readShort();
        short childCount = (short)( __sequenceCount1 + __sequenceCount2 );

        // User Java Code
        // e.g. ChildType[] children = new ChildType[childCount];
        //      currentElement.setChildren(children);
        {
            for (short __i=0; __i<__sequenceCount1; __i++) {
                decodeText(data);
            }
            for (short __i=0; __i<__sequenceCount2; __i++) {
                decodeAnswer(data);
            }
        }

        // User Java Code

    }

    private static void decodeText( DataInputStream data ) throws IOException {


        // User Java Code
        String textValue = data.readUTF();

        // User Java Code
        // e.g. currentElement.text = textValue;

        // User Java Code

    }

    private static void decodeAnswer( DataInputStream data ) throws IOException {


        // User Java Code
        byte presenceMaskFromCategory = data.readByte();
        boolean isAtCategoryPresent = (  ( presenceMaskFromCategory&0x1 )!=0  );
        String atCategory = null;
        if ( isAtCategoryPresent ) {
            atCategory = data.readUTF();
        }

        // User Java Code
        // e.g. if (isAtIdPresent) {
        //        currentElement = new ElementType(atId);
        //      } else {
        //        currentElement = new ElementType();
        //      }
        String textValue = data.readUTF();

        // User Java Code
        // e.g. currentElement.text = textValue;

        // User Java Code

    }

    private static void decodeCategory( DataInputStream data ) throws IOException {


        // User Java Code
        byte presenceMaskFromName = data.readByte();
        boolean isAtNamePresent = (  ( presenceMaskFromName&0x1 )!=0  );
        String atName = null;
        if ( isAtNamePresent ) {
            atName = data.readUTF();
        }

        // User Java Code
        // e.g. if (isAtIdPresent) {
        //        currentElement = new ElementType(atId);
        //      } else {
        //        currentElement = new ElementType();
        //      }
        String textValue = data.readUTF();

        // User Java Code
        // e.g. currentElement.text = textValue;

        // User Java Code

    }

}


/* END OF GENERATED FILE. PLEASE DO NOT EDIT THIS FILE, it was generated by an XSLT Transformation */