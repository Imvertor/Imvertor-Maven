package nl.imvertor.XmiCompiler;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Base64.Decoder;
import java.util.List;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.XMLStreamWriter;

public class XMIImageExporter {
    
  public List<Image> export(InputStream xmiStreamIn, OutputStream xmiStreamOut) throws Exception {
    String name = null; 
    String imageID = null;
    boolean isImage = false;
    List<Image> imageList = new ArrayList<>();
    StringBuffer imageDataBuffer = new StringBuffer();
    Decoder base64Decoder = Base64.getDecoder();
    XMLInputFactory xmlInputFactory = XMLInputFactory.newInstance();
    xmlInputFactory.setProperty(XMLInputFactory.IS_REPLACING_ENTITY_REFERENCES, Boolean.FALSE);
    XMLStreamReader reader = xmlInputFactory.createXMLStreamReader(xmiStreamIn);
    XMLStreamWriter writer = XMLOutputFactory.newInstance().createXMLStreamWriter(xmiStreamOut);
    boolean hasNext;
    do {
      switch (reader.getEventType()) {
      case XMLStreamConstants.START_DOCUMENT:
        writer.writeStartDocument(reader.getEncoding(), reader.getVersion());
        break;
      case XMLStreamConstants.END_DOCUMENT:
        writer.writeEndDocument();
        break;
      case XMLStreamConstants.START_ELEMENT:
        writer.writeStartElement(reader.getPrefix(), reader.getLocalName(), def(reader.getNamespaceURI(), ""));
        for (int i = 0; i < reader.getNamespaceCount(); i++)
          writer.writeNamespace(reader.getNamespacePrefix(i), reader.getNamespaceURI(i));
        for (int i = 0; i < reader.getAttributeCount(); i++)
          writer.writeAttribute(reader.getAttributePrefix(i), def(reader.getAttributeNamespace(i), ""), 
              reader.getAttributeLocalName(i), reader.getAttributeValue(i));
        if (reader.getLocalName().equals("EAImage")) {
          isImage = true;
          name = reader.getAttributeValue(null, "name");
          imageID = reader.getAttributeValue(null, "imageID");
        }
        break;
      case XMLStreamConstants.END_ELEMENT:
        if (isImage) {
          byte[] imageData = base64Decoder.decode(imageDataBuffer.toString());
          imageDataBuffer.setLength(0);
          imageList.add(new Image(name, imageID, imageData));
          writer.writeComment("Image data removed");
          isImage = false;
        }
        writer.writeEndElement();
        break;
      case XMLStreamConstants.CHARACTERS:
        if (isImage) {
          imageDataBuffer.append(reader.getText().replaceAll("\\s+", ""));
        } else {
          writer.writeCharacters(reader.getText());
        }
        break;
      case XMLStreamConstants.CDATA:
        writer.writeCData(reader.getText());
        break;
      case XMLStreamConstants.COMMENT:
        writer.writeComment(reader.getText());
        break;
      case XMLStreamConstants.PROCESSING_INSTRUCTION:
        writer.writeProcessingInstruction(reader.getPITarget(), reader.getPIData());
        break;
      }
      hasNext = reader.hasNext();
      if (hasNext)
        reader.next();
    } while (hasNext);
    return imageList;
  }
  
  public static final class Image {
    
    private String name;
    private String imageID;
    private byte[] data;
    
    public Image(String name, String imageID, byte[] data) {
      this.name = name;
      this.imageID = imageID;
      this.data = data;
    }

    public String getName() {
      return name;
    }
    
    public String getImageID() {
      return imageID;
    }

    public byte[] getData() {
      return data;
    }
    
  }
  
  private String def(String text, String def) {
    return text == null ? def : text;
  }

  /*
  public static void main(String[] args) throws Exception {
    XMIImageExporter exporter = new XMIImageExporter();
    try (FileInputStream xmiFis = new FileInputStream(new File("D:\\Projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\Tasks-GIThub\\xmi\\GIThub-issues.qea.xmi")); 
        FileOutputStream xmiFos = new FileOutputStream(new File("D:\\Projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\Tasks-GIThub\\xmi\\GIThub-issues.qea.out.xmi"))) {
      List<Image> images = exporter.export(xmiFis, xmiFos);
      for (Image image: images) {
        System.out.println(image.name);
        System.out.println(image.imageID);
        try (FileOutputStream imgFos = new FileOutputStream(new File("D:\\Projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\Tasks-GIThub\\xmi\\Images\\" + image.imageID + "_" + image.name))) {
          imgFos.write(image.data);
        }
      }
    }
  }
  */
}
