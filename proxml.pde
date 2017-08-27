//package proxml;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Hashtable;

import processing.core.PApplet;

/**
 * Use XMLInOut for simple loading and saving of XML files. If you load a xml file
 * the parsed XMLElement is passed to the xmlEvent() method in your sketch. To be
 * able to load xml files you have to implement this function, other wise you get an 
 * exception. It is also possible to implement this function in another object, to
 * do so you have to give the constructor a reference to your object.
 * 
 * 
 * @example proxml
 * @related XMLElement
 */
public class XMLInOut{

	/**
	 * Loader for loading XML in background while running the sketch.
	 * @author tex
	 *
	 */
	private class Loader implements Runnable{

		/**
		 * String to keep the String of the document to parse
		 */
		Reader document;

		/**
		 * String to keep the String of the document to parse
		 */
		Reader keep;
		
		/**
		 * Object handling the incoming XML
		 */
		Object xmlHandler;

		Loader(final Reader i_document, final Object i_xmlHandler){
			document = i_document;
			xmlHandler = i_xmlHandler;
		}

		/**
		 * Returns the source of the desired document
		 * @return
		 */
		String getSource(){
			int iChar;
			StringBuffer result = new StringBuffer();
			try{
				while ((iChar = keep.read()) != -1){
					result.append((char) iChar);
				}
			}catch (Exception e){
				return ("fails");
			}
			return result.toString();
		}

		private boolean firstTag = false;

		private boolean rootNode = false;

		private int line = 0;

		/**
		 * Parses a given String and gives back box with the parsed Element and the
		 * String still have to be parsed.
		 * @param toParse String
		 * @return BoxToParseElement
		 */
		private XMLElement parseDocument(Reader document){

			firstTag = true;
			rootNode = true;

			int iChar; //keeps the int value of the current char
			char cChar; //keeps the char value of the current char

			StringBuffer sbText = new StringBuffer(); //StringBuffer to parse words in
			boolean bText = false; //has a word been parsed
			try{
				while ((iChar = document.read()) != -1){ //as long there is something to read
					cChar = (char) iChar; //get the current char value
					switch (cChar){ //check the char value
						case '\b':
							break;
						case '\n':
							line++;
							break;
						case '\f':
							break;
						case '\r':
							break;
						case '\t':
							break;
						case '<': //this opens a tag so...
							if (bText){
								bText = false;
								actualElement.addChild(new XMLElement(sbText.toString(), true));
								sbText = new StringBuffer();
							}
							if ((iChar = document.read()) != -1){ //check the next sign...
								cChar = (char) iChar; //get its char value..

								if (cChar == '/'){ //in this case we have an end tag
									document = handleEndTag(result, document); // and handle it
									break;
								}else if (cChar == '!'){ //this could be a comment, but we need a further test
									if ((iChar = document.read()) != -1){ //you should know this now
										cChar = (char) iChar; //also this one
										if (cChar == '-'){ //okay its a comment
											document = handleComment(document); //handle it
											break;
										}else if (cChar == '['){//seems to be CDATA Section
											document = handleCDATASection(document);
											break;
										}else if (cChar == 'D'){//seems to be Doctype Section
											document = handleDoctypeSection(document);
											break;
										}
									}
								}
							}

							document = handleStartTag(document, new StringBuffer().append(cChar));

							break;
						default:
							if (!(cChar == ' ' && !bText)){
								bText = true;
								if (cChar == '&'){
									document = handleEntity(document, sbText);
								}else{
									sbText.append(cChar);
								}
							}
					}
				}
			}catch (Exception e){
				e.printStackTrace();
			}
			return result;
		}

		/**
		 * Parses a TemplateTag and extracts its Name and Attributes.
		 * @param page Reader
		 * @param alreadyParsed StringBuffer
		 * @return Reader
		 * @throws Exception
		 */
		private Reader handleStartTag(Reader page, StringBuffer alreadyParsed) throws Exception{
			int iChar;
			char cChar;

			boolean bTagName = true;
			boolean bSpaceBefore = false;
			boolean bLeftAttribute = false;

			StringBuffer sbTagName = alreadyParsed;
			StringBuffer sbAttributeName = new StringBuffer();
			StringBuffer sbAttributeValue = new StringBuffer();
			StringBuffer sbActual = sbTagName;

			Hashtable attributes = new Hashtable();
			boolean inValue = false;
			char oChar = ' ';

			while ((iChar = page.read()) != -1){
				cChar = (char) iChar;
				switch (cChar){
					case '\b':
						break;
					case '\f':
						break;
					case '\r':
						break;
					case '\n':
						line++;
					case '\t':
					case ' ':
						if (!bSpaceBefore){
							if (!inValue){
								if (bTagName){
									bTagName = false;
								}else{
									String sAttributeName = sbAttributeName.toString();
									String sAttributeValue = sbAttributeValue.toString();
									attributes.put(sAttributeName, sAttributeValue);

									sbAttributeName = new StringBuffer();
									sbAttributeValue = new StringBuffer();
									bLeftAttribute = false;
								}
								sbActual = sbAttributeName;
							}else{
								sbActual.append(cChar);
							}
						}
						bSpaceBefore = true;
						break;
					case '=':
						if (!inValue){
							sbActual = sbAttributeValue;
							bLeftAttribute = true;
						}else{
							sbActual.append(cChar);
						}
						break;
					case '"':
						inValue = !inValue;
						try{
							if (!inValue && sbActual.charAt(sbActual.length() - 1) == ' '){
								sbActual.deleteCharAt(sbActual.length() - 1);
							}
						}catch (java.lang.StringIndexOutOfBoundsException e){
							System.out.println(sbActual.toString());
						}
						bSpaceBefore = false;
						break;
					case '\'':
						break;
					case '/':
						if (inValue)
							sbActual.append(cChar);
						break;
					case '>':
						if (bLeftAttribute){
							String sAttributeName = sbAttributeName.toString();
							String sAttributeValue = sbAttributeValue.toString();
							attributes.put(sAttributeName, sAttributeValue);
						}
						String sTagName = sbTagName.toString();
						if (firstTag){
							firstTag = false;
							if (!(sTagName.equals("doctype") || sTagName.equals("?xml")))
								throw new RuntimeException("XML File has no valid header");
						}else{
							if (rootNode && !firstTag){
								rootNode = false;
								result = new XMLElement(sTagName, attributes);
								actualElement = result;
							}else{
								XMLElement keep = new XMLElement(sTagName, attributes);
								actualElement.addChild(keep);
								if (oChar != '/')
									actualElement = keep;
							}
						}

						return page;

					default:
						bSpaceBefore = false;
						sbActual.append(cChar);
				}
				oChar = cChar;
			}

			throw new RuntimeException("Error in line:"+line);
		}

		/**
		 * Parses the end tags of a XML document
		 * 
		 * @param toParse Reader
		 * @return Reader
		 * @throws Exception
		 */
		private Reader handleEndTag(XMLElement xmlElement, Reader toParse) throws Exception{
			int iChar;
			char cChar;
			while ((iChar = toParse.read()) != -1){

				cChar = (char) iChar;
				switch (cChar){
					case '\b':
						break;
					case '\n':
						line++;
						break;
					case '\f':
						break;
					case '\r':
						break;
					case '\t':
						break;
					case '>':
						if (!actualElement.equals(xmlElement))
							actualElement = actualElement.getParent();
						return toParse;
					default:
				}
			}
			throw new RuntimeException("Error in line:"+line);
		}

		/**
		 * Parses the comments of a XML document
		 * 
		 * @param toParse Reader
		 * @return Reader
		 * @throws Exception
		 */
		private Reader handleComment(Reader toParse) throws Exception{
			int iChar;
			char cChar;
			char prevChar = ' ';

			while ((iChar = toParse.read()) != -1){
				cChar = (char) iChar;
				if (prevChar == '-' && cChar == '>'){
					return toParse;
				}
				prevChar = cChar;
			}
			throw new RuntimeException("Comment is not correctly closed in Line:"+line);
		}
		
		/**
		 * Parses the Doctype section of a XML document
		 * 
		 * @param toParse Reader
		 * @return Reader
		 * @throws Exception
		 */
		private Reader handleDoctypeSection(Reader toParse) throws Exception{
			int iChar;
			char cChar;
			char prevChar = ' ';
			
			boolean entities = false;

			while ((iChar = toParse.read()) != -1){
				cChar = (char) iChar;
				if(cChar == '[')entities = true;
				if (cChar == '>'){
					if(prevChar == ']' && entities || !entities)
					return toParse;
				}
				prevChar = cChar;
			}
			throw new RuntimeException("Comment is not correctly closed in Line:"+line);
		}

		/**
		 * Parses Entities of a document
		 * 
		 * @param toParse
		 * @param stringBuffer
		 * @return
		 * @throws Exception
		 */
		private Reader handleEntity(Reader toParse, final StringBuffer stringBuffer) throws Exception{
			int iChar;
			char cChar;
			final StringBuffer result = new StringBuffer();
			int counter = 0;

			while ((iChar = toParse.read()) != -1){
				cChar = (char) iChar;
				result.append(cChar);
				if (cChar == ';'){
					final String entity = result.toString().toLowerCase();
					if (entity.equals("lt;"))
						stringBuffer.append("<");
					else if (entity.equals("gt;"))
						stringBuffer.append(">");
					else if (entity.equals("amp;"))
						stringBuffer.append("&");
					else if (entity.equals("quot;"))
						stringBuffer.append("\"");
					else if (entity.equals("apos;"))
						stringBuffer.append("'");
					break;
				}
				counter++;
				if (counter > 4)
					throw new RuntimeException("Illegal use of &. Use &amp; entity instead. Line:"+line);
			}

			return toParse;
		}

		/**
		 * Parses a CData Section of a document
		 * @param toParse
		 * @return
		 * @throws Exception
		 */
		private Reader handleCDATASection(Reader toParse) throws Exception{
			int iChar;
			char cChar;
			StringBuffer result = new StringBuffer();
			int counter = 0;
			boolean checkedCDATA = false;

			while ((iChar = toParse.read()) != -1){
				cChar = (char) iChar;
				if (cChar == ']'){
					XMLElement keep = new XMLElement(result.toString());
					keep.cdata = true;
					keep.pcdata = true;
					actualElement.addChild(keep);
					break;
				}
				result.append(cChar);
				counter++;
				if (counter > 5 && !checkedCDATA){
					checkedCDATA = true;
					if (!result.toString().toUpperCase().equals("CDATA["))
						throw new RuntimeException(
							"Illegal use of <![. " + 
							"These operators are used to start a CDATA section. <![CDATA[]]>" +
							" Line:" + line
						);
					result = new StringBuffer();
				}
			}

			if ((char) toParse.read() != ']')
				throw new RuntimeException("Wrong Syntax at the end of a CDATA section <![CDATA[]]> Line:"+line);
			if ((char) toParse.read() != '>')
				throw new RuntimeException("Wrong Syntax at the end of a CDATA section <![CDATA[]]> Line:"+line);

			//XMLElement keep = new XMLElement(sTagName,attributes);
			//actualElement.addChild(keep);
			//if(oChar != '/')actualElement = keep;
			return toParse;
		}
		XMLElement xmlElement;
		public void run(){
			xmlElement = parseDocument(document);
			
			if(xmlHandler == null)  return;
			
			try{
				xmlEventMethod.invoke(xmlHandler, new Object[] {xmlElement});
			}catch (IllegalAccessException e){
				// TODO Auto-generated catch block
				e.printStackTrace();
			}catch (InvocationTargetException e){
				// TODO Auto-generated catch block
				e.printStackTrace();
			}catch(NullPointerException e){
				throw new RuntimeException("You need to implement the xmlEvent() function to handle the loaded xml files.");
			}
		}

	}

	/**
	 * XML document start
	 */
	private static final String docStart = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>";

	/**
	 * the parent element to put the children elements in while parsing
	 */
	private XMLElement actualElement;

	/**
	 * the result element for loading a document
	 */
	private XMLElement result;

	/**
	 * Parent PApplet instance
	 */
	private final PApplet pApplet;
	private final Object parent;

	/**
	 * Method to call when xml is loaded
	 */
	private Method xmlEventMethod;

	/**
	 * Initializes a new XMLInOut Object for loading and saving XML files. If you give
	 * the constructor only a reference to your application it looks for the xmlEvent
	 * method in your sketch. If you also give it a reference to a further object it
	 * calls the xmlEvent method in this object.
	 * @param pApplet PApplet, the Applet proXML is running in
	 */
	public XMLInOut(final PApplet pApplet){
		this.pApplet = pApplet;
		parent = pApplet;

		try{
			xmlEventMethod = pApplet.getClass().getMethod("xmlEvent", new Class[] {XMLElement.class});
		}catch (Exception e){
			
		}
	}

	/**
	 * @param pApplet PApplet, the Applet proXML is running in
	 * @param i_parent Object, the object that contains the xmlEvent function
	 */
	public XMLInOut(final PApplet pApplet, final Object i_parent){
		this.pApplet = pApplet;
		parent = i_parent;

		try{
			xmlEventMethod = i_parent.getClass().getMethod("xmlEvent", new Class[] {XMLElement.class});
		}catch (Exception e){
		
		}
	}

	/**
	 * Modified openStream Method from PApplet.
	 * @param filename
	 * @return InputStream
	 */
	private InputStream openStream(String filename){
		InputStream stream = null;

		try{
			URL url = new URL(filename);
			stream = url.openStream();
			return stream;

		}catch (MalformedURLException e){
			// not a url, that's fine

		}catch (IOException e){
			throw new RuntimeException("Error downloading from URL " + filename);
		}

		// if not online, check to see if the user is asking for a file
		// whose name isn't properly capitalized. this helps prevent issues
		// when a sketch is exported to the web, where case sensitivity
		// matters, as opposed to windows and the mac os default where
		// case sensitivity does not.
		//if (!pApplet.online){
			try{
				// first see if it's in a data folder
				File file = new File(sketchPath("") + File.separator + "data", filename);
				if (!file.exists()){
					// next see if it's just in this folder
					file = new File(sketchPath(""), filename);
				}
				if (file.exists()){
					try{
						String path = file.getCanonicalPath();
						String filenameActual = new File(path).getName();
						// if the actual filename is the same, but capitalized
						// differently, warn the user. unfortunately this won't
						// work in subdirectories because getName() on a relative
						// path will return just the name, while 'filename' may
						// contain part of a relative path.
						if (filenameActual.equalsIgnoreCase(filename) && !filenameActual.equals(filename)){
							throw new RuntimeException("This file is named " + filenameActual + " not " + filename + ".");
						}
					}catch (IOException e){
					}
				}

				// if this file is ok, may as well just load it
				stream = new FileInputStream(file);
				if (stream != null)
					return stream;

				// have to break these out because a general Exception might
				// catch the RuntimeException being thrown above
			}catch (IOException ioe){
			}catch (SecurityException se){
			}
		//}

		try{
			// by default, data files are exported to the root path of the jar.
			// (not the data folder) so check there first.
			stream = pApplet.getClass().getResourceAsStream(filename);
			if (stream != null)
				return stream;

			// hm, check the data subfolder
			stream = pApplet.getClass().getResourceAsStream("data/" + filename);
			if (stream != null)
				return stream;

			// attempt to load from a local file, used when running as
			// an application, or as a signed applet
			try{ // first try to catch any security exceptions
				try{
					File file = new File(sketchPath(""), filename);
					stream = new FileInputStream(file);
					if (stream != null)
						return stream;

				}catch (Exception e){
				} // ignored

				try{
					stream = new FileInputStream(new File("data", filename));
					if (stream != null)
						return stream;
				}catch (IOException e2){
				}

				try{
					stream = new FileInputStream(filename);
					if (stream != null)
						return stream;
				}catch (IOException e1){
				}

			}catch (SecurityException se){
			} // online, whups

			if (stream == null){
				throw new IOException("openStream() could not open " + filename);
			}
		}catch (Exception e){
		}
		return null; // #$(*@ compiler
	}

	/**
	 * Use this method to load an xml file. If the given String is xml it is
	 * directly parsed and converted to a XMLElement. Be aware that it has to
	 * start with &quot;&lt;?xml&quot to be detected as xml.
	 * If you call the function with an url the according file is loaded. You 
	 * can load xml files from your harddisk or the internet. Both works in
	 * an application if you export it as an applet it is not possible to 
	 * directly load xml from external sources, because of java security resctictions.
	 * If you want to load external sources you have to use an application on
	 * the serverside that passes the file to your applet. You will find
	 * examples using php in the processing forum.
	 * 
	 * To handle the loaded XML File you have to implement the method xmlEvent(XMLElement element).
	 * If the xml file is loaded it is send to this method.
	 * 
	 * @param documentUrl String, url from where the Element has to be loaded
	 * @example proxml
	 * @shortdesc Loads the XMLElement from a given path.
	 * @related XMLInOut
	 * @related loadElementFrom ( )
	 * @related saveElement ( )
	 */
	public void loadElement(final String documentUrl){

		Thread loader;
		if (documentUrl.startsWith("<?xml")){
			loader = new Thread(new Loader(new StringReader(documentUrl),parent));
		}else{
			try{
				InputStream test = openStream(documentUrl);
				loader = new Thread(new Loader(new BufferedReader(new InputStreamReader(test)),parent));
			}catch (Exception e){
				throw new RuntimeException("proXML was not able to load the given xml-file: " + documentUrl + " Please check if you have entered the correct url.");
			}
		}
		try{
			loader.start();
		}catch (Exception e){
			throw new RuntimeException("proXML was not able to read the given xml-file: " + documentUrl + " Please make sure that you load a file that contains valid xml.");
		}
	}
	
	/**
	 * Use this method to load an xml file. If the given String is xml it is
	 * directly parsed and converted to a XMLElement. Be aware that it has to
	 * start with &quot;&lt;?xml&quot to be detected as xml.
	 * If you call the function with an url the according file is loaded. You 
	 * can load xml files from your harddisk or the internet. Both works in
	 * an application if you export it as an applet it is not possible to 
	 * directly load xml from external sources, because of java security resctictions.
	 * If you want to load external sources you have to use an application on
	 * the serverside that passes the file to your applet. You will find
	 * examples using php in the processing forum.
	 * 
	 * @param documentUrl String, url from where the Element has to be loaded
	 * @example proxml_loadElementFrom
	 * @shortdesc Loads the XMLElement from a given path.
	 * @related XMLInOut
	 * @related loadElementFrom ( )
	 * @related saveElement ( )
	 */
	public XMLElement loadElementFrom(final String documentUrl){
		Loader loader;
		if (documentUrl.startsWith("<?xml")){
			loader = new Loader(new StringReader(documentUrl),null);
		}else{
			try{
				InputStream test = openStream(documentUrl);
				loader = new Loader(new BufferedReader(new InputStreamReader(test)),null);
			}catch (Exception e){
				throw new RuntimeException("proXML was not able to load the given xml-file: " + documentUrl + " Please check if you have entered the correct url.");
			}
		}
		try{
			loader.run();
			return loader.xmlElement;
		}catch (Exception e){
			throw new RuntimeException("proXML was not able to read the given xml-file: " + documentUrl + " Please make sure that you load a file that contains valid xml.");
		}
	}

	/**
	 * Saves the XMLElement to a given Filename.
	 * 
	 * @param documentUrl String, url to save the XMLElement as XML File 
	 * @example proxml
	 * @shortdesc Saves the XMLElement to a given File.
	 * @related XMLInOut
	 * @related loadElement ( )
	 * @usage Application
	 */
	public void saveElement(final XMLElement xmlElement, String filename){
		try{
			File file;
			//if (!pApplet.online){
				file = new File(sketchPath("") + File.separator + "data", filename);
				System.out.println(sketchPath("") + File.separator + "data");
				if (!file.exists()){
					final String parent = file.getParent();

					if (parent != null){
						File unit = new File(parent);
						if (!unit.exists())
							unit.mkdirs();
					}
				}
			//}else{
				//file = new File(pApplet.getClass().getResource("data/" + filename).toURI());
			//}

			PrintWriter output = new PrintWriter(new FileOutputStream(file));
			output.println(docStart);
			xmlElement.printElementTree(output, "  ");
			output.flush();
			output.close();
		}catch (Exception e){
			e.printStackTrace();
			System.out.println(sketchPath("") + File.separator + "data");
			System.out.println("You cannot write to this destination. Make sure destionation is a valid path");
		}
	}

	/**
	 * The following methods are for parsing the XML Files
	 */

}

//package proxml;

import java.util.*;
import java.io.*;

/**
 * XMLElement is the basic class of proXML. You can build a XMLElement and add 
 * Attributes and children, or load it from a certain path using XMLInOut. Text
 * is also handled as XMLElement, so if you want to get the text of an element
 * you have to call element.firstChild().getText(). If you have a part where
 * xml nodes are inside text they seperate the text into several elements, so for
 * example &quot;this is &lt;bold&gt;bold&lt;/bold&gt; ..&quot; would result in the following
 * element list: &quot;this is &quot;,&lt;bold&gt;,&quot;bold&quot;,&lt;/bold&gt;,&quot; ..&quot;
 * @example proxml
 * @related XMLInOut
 */

public class XMLElement{
	/**
     * Holds the values and keys of the elements attributes.
     */
    Hashtable attributes;

    /**
     * Vector keeping the children of this Element
     */
    private Vector children;
	
	/**
	 * true if this element is empty 
	 */
	private boolean empty = true;
	
	/**
	 * true if this element is a pcdata section
	 */
	boolean pcdata;
	
	boolean cdata = false;
	
	 /**
     * Holds the parent of this Element
     */
	private XMLElement parent;
	
    /**
     * String holding the kind of the Element (the tagname)
     */
    private String element;
	
	/**
     * Initializes a new XMLElement with the given name, attributes and children.
     * @param name String, name of the element
     * @param attributes Hashtable, attributes for the element, with names and values
     * @param children Vector, the children of the element
     * @param pcdata boolean, true if the element is a pcdata section
     */
    private XMLElement (
		final String name, 
		final Hashtable attributes, 
		final Vector children, 
		final boolean pcdata
	) {
		this.element = name;
		this.attributes = attributes;
        this.children = children;
		this.pcdata = pcdata;
    }
	
	/**
	 * Initializes a new XMLElement with the given name.
	 * @param name String, name of the element
	 * @param pcdata boolean, true if the element is a pcdata section
	 */
	public XMLElement(
		final String name, 
		final boolean pcdata
	){
		this(name,new Hashtable(),new Vector(),pcdata);
	}

    /**
     * Initializes a new XMLElement with the given name, attributes and children.
     * @param name String, name of the element
     * @param attributes Hashtable, attributes for the element, with names and values
     * @param children Vector, the children of the element
     */
    public XMLElement (
		final String name, 
		final Hashtable attributes, 
		final Vector children
	) {
		this(name,attributes,children,false);
    }
	
	/**
     * Initializes a XMLElement with the given name, but without children and attributes.
     * @param name String, name of the element
     */

    public XMLElement (
		final String name
	) {
        this(name, new Hashtable(), new Vector());
    }

    /**
     * Initializes a XMLElement with the given name and children.
     * @param name String, name of the element
     * @param children Vector, children of the element
     */

    public XMLElement (
		final String name, 
		final Vector children
	) {
        this(name, new Hashtable(), children);
    }

    /**
     * Initializes a new XMLElement with the given name and attributes.
     * @param name String, name of the element
     * @param attributes Hashtable, attributes of the element, with names and values
     */

    public XMLElement (
		final String name, 
		final Hashtable attributes
	){
        this(name, attributes, new Vector());
    }
	
	
	
	/**
     * Checks if a Vector has Content
     * @param toCheck Vector
     * @return boolean
     */
    private boolean has (Vector toCheck) {
        if (toCheck.isEmpty() || toCheck == null) {
            return false;
        } else {
            return true;
        }
    }
	
	/**
	 * Use this method to check if the XMLElement is a text element. 
	 * @return boolean, true if the XMLElement is a PCDATA section.
	 * @example proxml_isPCDATA
	 * @shortdesc Checks if a XMLElement is a text element
	 * @related XMLElement
	 * @related getElement ( )
	 */
	public boolean isTextElement(){
		return pcdata;
	}
	
	/**
	 * Use this method to get the name of a XMLElement. If the XMLElement is a 
	 * PCDATA section getElement() gives you its text.
	 * @return String, the name of the element or the text if it is a text element
	 * @example proxml_getElement
	 * @shortdesc Use this method to get the name or text of an XMLElement. 
	 * @related XMLElement
	 * @related isTextElement ( )
	 */
	public String getElement(){
		return element;
	}
	
	/**
	 * Returns the name of the XML object this is the name of the 
	 * tag that represents the element in the XML file. For example, TITLE is the elementName 
	 * of an HTML TITLE tag. If the XML object is a text element this method returns null.
	 * @return String the name of the element
	 * @shortdesc Returns the name of the element.
	 */
	public String getName(){
		if(isTextElement())return null;
		return element;
	}
	
	/**
	 * If the XML object is a text element this method return the text of the element, otherwise
	 * it returns null.
	 * @return String, the text of a text element
	 * @shortdesc Returns the text of the element.
	 */
	public String getText(){
		if(isTextElement())return element;
		return null;
	}

    /**
     * Returns a String Array with all attribute names of an Element. Use 
     * getAttribute() to get the value for an attribute.
     * @return String[], Array with the Attributes of an Element
     * @example proxml_getAttributes
     * @shortdesc Returns a String Array with all attribute names of an Element.
     * @related XMLElement
     * @related getAttribute ( )
     * @related getIntAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttributes ( )
     * @related hasAttribute ( )
     * @related countAttributes ( )
     * @related addAttribute ( )
     */
    public String[] getAttributes () {
		Object[] attributeArray = attributes.keySet().toArray();
		String[] result = new String[attributeArray.length];
		for(int i = 0; i < attributeArray.length; i++){
			result[i] = (String)attributeArray[i];
		}
        return result;
    }

    /**
     * Use getAttribute() to get the value of an attribute as a string. If your are
     * sure, the value is an int or a float value you can also use getIntAttribute() or 
     * getFloatAttribute() to get the numeric value without a cast.
     * @param key String, the name of the attribute you want the value of
     * @return String, the value to the given attribute
     * @example proxml_getAttributes
     * @shortdesc Returns the value of a given attribute.
	  * @related XMLElement
     * @related getAttributes ( )
     * @related getIntAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttributes ( )
     * @related hasAttribute ( )
     * @related countAttributes ( )
     * @related addAttribute ( )
     */
    public String getAttribute (String key) {
		String result = (String)attributes.get(key);
		if(result == null)throw new InvalidAttributeException(this.element,key);
        return result;
    }
	
	/**
	 * Use getIntAttribute() to get the value of an attribute as int value. You 
	 * can only use this method on attributes that are numeric, otherwise you get 
	 * a InvalidAttributeException. 
	 * @param key String, the name of the attribute you want the value of
	 * @return int, the value of the attribute
	 * @example proxml
	 * @shortdesc Use getIntAttribute() to get the value of an attribute as int value.
	  * @related XMLElement
	 * @related getAttributes ( )
     * @related getAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttributes ( )
     * @related hasAttribute ( )
     * @related countAttributes ( )
     * @related addAttribute ( )
	 */
	public int getIntAttribute (String key){
		String attributeValue = (String)attributes.get(key);
		if(attributeValue==null)throw new InvalidAttributeException(this.element,key);
		try{
			return Integer.parseInt((String)attributes.get(key));
		}catch (NumberFormatException e){
			throw new InvalidAttributeException(this.element,key,"int");
		}
	}
	
	/**
	 * Use getFloatAttribute() to get the value of an attribute as float value. You 
	 * can only use this method on attributes that are numeric, otherwise you get 
	 * a InvalidAttributeException. 
	 * @param key String, the name of the attribute you want the value of
	 * @return float, the value of the attribute
	 * @example proxml
	 * @shortdesc Use getFloatAttribute() to get the value of an attribute as float value.
	  * @related XMLElement
	 * @related getAttributes ( )
     * @related getAttribute ( )
     * @related getIntAttribute ( )
     * @related hasAttributes ( )
     * @related hasAttribute ( )
     * @related countAttributes ( )
     * @related addAttribute ( )
	 */
	public float getFloatAttribute (String key){
		String attributeValue = (String)attributes.get(key);
		if(attributeValue==null)throw new InvalidAttributeException(this.element,key);
		try{
			return Float.parseFloat((String)attributes.get(key));
		}catch (NumberFormatException e){
			throw new InvalidAttributeException(this.element,key,"int");
		}
	}

    /**
     * Use this method to check if the XMLElement has attributes.
     * @return boolean, true if the XMLElement has attributes
     * @example proxml_hasAttributes
	  * @related XMLElement
     * @related getAttributes ( )
     * @related getAttribute ( )
     * @related getIntAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttribute ( )
     * @related countAttributes ( )
     * @related addAttribute ( )
     */
    public boolean hasAttributes () {
        return!attributes.isEmpty();
    }

    /**
     * This method checks if the XMLElement has the given Attribute.
     * @param key String, attribute you want to check
     * @return boolean, true if the XMLElement has the given attribute
     * @example proxml_hasAttribute
     * @related getAttributes ( )
     * @related getAttribute ( )
     * @related getIntAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttributes ( )
     * @related countAttributes ( )
     * @related addAttribute ( )
     */
    public boolean hasAttribute (String key) {
        return attributes.containsKey(key);
    }
	
	/**
	 * Use this method to count the attributes of a XMLElement.
	 * @return int, the number of attributes
	 * @example proxml_countAttributes
	  * @related XMLElement
	 * @related getAttributes ( )
     * @related getAttribute ( )
     * @related getIntAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttributes ( )
     * @related hasAttribute ( )
     * @related addAttribute ( )
	 */
	public int countAttributes(){
		return attributes.size();
		
	}

    /**
     * With addAttribute() you can add attributes to a XMLElement. The value
     * of attribute can be a String a float or an int. 
     * @param key String, name of the attribute
     * @param value String, int or float: value of the attribute
     * @example proxml
     * @shortdesc With addAttribute() you can add attributes to a XMLElement.
	  * @related XMLElement
     * @related getAttributes ( )
     * @related getAttribute ( )
     * @related getIntAttribute ( )
     * @related getFloatAttribute ( )
     * @related hasAttributes ( )
     * @related hasAttribute ( )
     * @related countAttributes ( )
     */
    public void addAttribute (String key, String value) {
		if(isTextElement())throw new InvalidAttributeException(key);
        attributes.put(key, value);
    }
	
    public void addAttribute (String key, int value) {
		addAttribute(key, value+"");
    }

    public void addAttribute (String key, float value) {
		addAttribute(key, value+"");
    }

    /**
     * With getParent() you can get the parent of a XMLElement. If the 
     * XMLElement is the root element it returns null.
     * @return XMLElement, the parent of the XMLElement or null 
     * if the XMLElement is the root element
     * @example proxml_getParent
     * @shortdesc With getParent() you can get the parent of a XMLElement.
	  * @related XMLElement
     * @related addChild ( )
     * @related countChildren ( )
     * @related getChild ( )
     * @related getChildren ( )
     * @related hasChildren ( )
     */
    public XMLElement getParent () {
        return parent;
    }

    /**
     * Use getChildren() to get an array with all children of an element. 
     * Each element in the array is a reference to an XML object that represents 
     * a child element.
     * @return XMLElement[], an Array of child elements
     * @example proxml_getChildren
     * @shortdesc Returns an Array with all the children of an element.
	  * @related XMLElement
     * @related addChild ( )
     * @related countChildren ( )
     * @related getChild ( )
     * @related getParent ( )
     * @related hasChildren ( )
     */
    public XMLElement[] getChildren () {
		Object[] childArray = children.toArray();
		XMLElement[] result = new XMLElement[childArray.length];
		for(int i = 0; i < childArray.length; i++){
			result[i] = (XMLElement)childArray[i];
		}
        return result;
    }
    
    /**
     * Evaluates the specified XML element and references the first child in the 
     * parent element's child list or null if the element does not 
     * have children.
     * @return XMLElement, the first child element
     * @shortdesc Returns the first child of the element.
     */
    public XMLElement firstChild(){
   	 if(hasChildren())return getChild(0);
   	 else return null;
    }
    
    /**
     * Returns the last child in the element's child list or null if the element does 
     * not have children.
     * @return XMLElement, the last child of the element
     * @shortdesc Returns the last child of the element.
     */
    public XMLElement lastChild(){
   	 if(hasChildren())return getChild(countChildren()-1);
   	 else return null;
    }
    
    /**
     * Returns the next sibling in the parent elements's child list or null if the node does 
     * not have a next sibling element.
     * @return XMLElement, the next sibling of the element
     * @shortdesc Returns the next sibling of the element.
     */
    public XMLElement nextSibling(){
   	 if(parent == null)return null;
   	 
   	 final int index = parent.children.indexOf(this);
   	 
   	 if(index < parent.countChildren()-1){
   		 return parent.getChild(index+1);
   	 }
   	
   	 return null;
    }
    
    /**
     * Returns the previous sibling in the parent node's child list or null if the node does 
     * not have a previous sibling node.
     * @return XMLElement, the previous sibling of the element.
     * @shortdesc Returns the previous sibling of the element.
     */
    public XMLElement previousSibling(){
   	 if(parent == null)return null;
   	 
   	 final int index = parent.children.indexOf(this);
   	 
   	 if(index > 0){
   		 return parent.getChild(index-1);
   	 }
   	
   	 return null;
    }
	
	/**
	 * Use getChild() to get a certain child element of a XMLElement. 
	 * With countAllChildren() you get the number of all children.
	 * @param i int, number of the child
	 * @return XMLElement, the child
	 * @example proxml
	 * @shortdesc Use getChild() to get a certain child element of a XMLElement.
	 * @related XMLElement
	 * @related addChild ( )
    * @related countChildren ( )
    * @related getChildren ( )
    * @related getParent ( )
    * @related hasChildren ( )
	 */
	public XMLElement getChild(int i){
		return ((XMLElement)children.get(i));
	}

    /**
     * Specifies whether or not the XML object has child nodes.
     * @return boolean, true if the specified XMLElement has one or more child nodes; otherwise false.
     * @example proxml_hasChildren
	  * @related XMLElement
     * @related addChild ( )
     * @related countChildren ( )
     * @related getChild ( )
     * @related getChildren ( )
     * @related getParent ( )
     */
    public boolean hasChildren () {
        return has(children);
    }
	
	/**
	 * With countChildren() you get the number of children of a XMLElement.
	 * @return int, the number of children
	 * @example proxml
	 * @related XMLElement
	 * @related addChild ( )
    * @related getChild ( )
    * @related getChildren ( )
    * @related getParent ( )
    * @related hasChildren ( )
	 */
	public int countChildren(){
		return children.size();
	}

   /**
	 * Adds the specified node to the XML element's child list. This method
    * operates directly on the element referenced by the childElement parameter; it
	 * does not append a copy of the element. If the element to be added already
	 * exists in another tree structure, appending the element to the new
	 * location will remove it from its current location. If the childElement
	 * parameter refers to a element that already exists in another XML tree
	 * structure, the appended child element is placed in the new tree structure
	 * after it is removed from its existing parent element.
	 * 
	 * @param element XMLElement, element you want to add as child
	 * @example proxml
	 * @shortdesc Adds the specified node to the XML element's child list.
	 * @related XMLElement
	 * @related addChild ( )
	 * @related countChildren ( )
	 * @related getChildren ( )
	 * @related getParent ( )
	 * @related hasChildren ( )
	 */
	public void addChild(XMLElement element){
		empty = false;
		element.parent = this;
		children.add(element);
	}
	
   /**
	 * @param element XMLElement, element you want to add as child
	 * @param position int, position where you want to insert the element
	 */
   public void addChild (XMLElement element, int position){
   	empty = false;
		element.parent = this;
      children.add(position, element);
    }
    
    /**
     * Removes the specified XML element from its parent. Also deletes all descendants of the element.
     * @param childNumber int, the number of the child to remove
     * @shortdesc Removes the specified XML element from its parent.
     * @related XMLElement
     * @related addChild ( )
     * @related countChildren ( )
     */
    public void removeChild(int childNumber){
   	 children.remove(childNumber);
   	 empty = children.size() == 0;
    }

    /**
     * Use getDepth to get the maximum depth of an Element to one of its leaves.
     * @return int, the maximum depth of an Element to one of its leaves
     * @example proxml_getDepth
	  * @related XMLElement
     * @related countAllChildren ( )
     * @related countAttributes ( )
     * @related countChildren ( )
     */
    public int getDepth () {
        int result = 0;
        XMLElement[] children = getChildren();
        for (int i = 0; i < children.length; i++) {
            result = Math.max(result, children[i].getDepth());
        }
        return 1 + result;
    }

    /**
     * This method returns the number of all nodes of a XMLElement.
     * @return int, the number of all decendents of an Element
     * @example proxml_countAllChildren
	  * @related XMLElement
     * @related getParent ( )
     * @related getDepth ( )
     * @related countAttributes ( )
     * @related countChildren ( )
     */
    public int countAllChildren () {
        int result = 0;
		XMLElement[] children = getChildren();
        for (int i = 0; i < children.length; i++) {
            result += children[i].countAllChildren();
        }
        return 1 + result;
    }

    /**
     * Gives back a vector with elements of the given kind being decendents of this Element
     * @param element String
     * @return Vector
     * @invisible
     */
    public Vector getSpecificElements (String element) {
        Vector result = new Vector();
		XMLElement[] children = getChildren();
        for (int i = 0; i < children.length; i++) {
            if (!children[i].isTextElement()) {
                result.addAll(children[i].getSpecificElements(element));
            }
            if (children[i].element.equals(element)) {
                result.add(children[i]);
            }
        }
        return result;
    }
	
    /**
     * Use toString to get the String representation of a XMLElement. The 
     * Methode gives you the starttag with the name and its attributes, or its text if 
     * it is a PCDATA section.
     * @return String, String representation of the XMLElement
     * @example proxml_toString
     * @shortdesc Use toString to get the String representation of a XMLElement.
	  * @related XMLElement
     * @related printElementTree ( )
     * @related getElement ( )
     * @related isTextElement ( )
     */
    public String toString () {
		if(isTextElement()){
			if(this.cdata){
				final StringBuffer result = new StringBuffer();
				result.append("<![CDATA[");
				result.append(getElement());
				result.append("]]>");
				return result.toString();
			}else{
				String result = getElement();
				result = result.replaceAll("&","&amp;");
				result = result.replaceAll("<","&lt;");
				result = result.replaceAll(">","&gt;");
				result = result.replaceAll("\"","&quot;");
				result = result.replaceAll("'","&apos;");
				return result;
			}
		}
        final StringBuffer result = new StringBuffer();
		result.append("<");
		result.append(element);
        for (Iterator it = attributes.keySet().iterator(); it.hasNext(); ) {
            String key = (String)it.next();
            result.append(" ");
			result.append(key);
			result.append("=\"");
			result.append(attributes.get(key));
			result.append("\"");
        }
		if(empty)result.append("/>");
		else result.append(">");
        return result.toString();
    }
	
 	/**
     * Use this method for a simple trace of the XML structure, beginning from a certain 
     * XMLElement.
     * @shortdesc Prints out the XML  content of the element.
     * @example proxml_printElementTree
	  * @related XMLElement
     * @related toString ( )
     */
    public void printElementTree(){
   	 printElementTree(" ");
    }
    
    /**
     * @param dist String, String for formating the output
     */
    public void printElementTree (String dist) {
        printElementTree("", dist);
    }
	
    /**
     * @param start String, String to put before the element
     */
    void printElementTree(String start, String dist){
		System.out.println(start + this);
		for (int i = 0; i < children.size(); i++){
			((XMLElement) children.get(i)).printElementTree(start + dist, dist);
		}
		if (!empty){
			System.out.println(start + "</" + element + ">");
		}
	}

    /**
     * Prints the tree of this Element with the given distance
     * 
     * @param dist String
     * @param output PrintWriter
     * @related XMLElement
     */
    void printElementTree (PrintWriter output, String dist) {
        printElementTree(output,"", dist);
    }

    /**
     * Prints the tree of this Element with the given distance and start string.
     * @param start String
     * @param dist String
     * @param output PrintWriter
     */
    void printElementTree (PrintWriter output,String start, String dist) {
		output.println(start + this);
        for (int i = 0; i < children.size(); i++) {
            ((XMLElement)children.get(i)).printElementTree(output,start + dist, dist);
        }
		if(!empty){
			output.println(start + "</" + element + ">");
		}
    }
	
	
	
}

//package proxml;

/**
 * An InvalidDocumentException occurs when you try to load a file that does not contain XML.
 * Or the XML file you load has mistakes.
 * @nosuperclasses
 */

public class InvalidDocumentException extends RuntimeException{
    /**
	 * 
	 */
	private static final long serialVersionUID = -3635832302276564720L;

	public InvalidDocumentException () {
        super("This is not a parsable URL");
    }

    public InvalidDocumentException (String url) {
        super(url+" is not a parsable URL");
    }
    
    public InvalidDocumentException (String url, Exception i_exception) {
       super(url+" is not a parsable URL",i_exception);
   }

}

//package proxml;

/**
 * An InvalidAttributeException occurs when a XMLElement does not have the requested 
 * attribute, or when you use getIntAttribute() or getFloatAttribute() for Attributes 
 * that are not numeric. Another reason could be that you try to add an attribute to a PCDATA 
 * section.
 * @nosuperclasses
 */

public class InvalidAttributeException extends RuntimeException{

	public InvalidAttributeException(String attributeName){
		super("You can't add the attribute " + attributeName + " to a PCDATA section.");
	}

	public InvalidAttributeException(String elementName, String attributeName){
		super("The XMLElement " + elementName + " has no attribute " + attributeName + "!");
	}

	public InvalidAttributeException(String elementName, String attributeName, String type){
		super("The XMLElement " + elementName + " has no attribute " + attributeName + " of the type " + type + "!");
	}

}