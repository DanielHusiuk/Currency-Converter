import xml.etree.ElementTree as ET
try:
    tree = ET.parse('Currency converter/View/Base.lproj/Main.storyboard')
    print("XML is valid.")
    root = tree.getroot()
    print("Root tag:", root.tag)
except Exception as e:
    print("XML error:", e)
