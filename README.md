# godot-xml
A script I wrote to parse xmls for my game's journal, notes, and books system.

All opening/starting tags must have a closing tag.

The load_xml function is the most useful function here.
It can read an xml file, then return a dictionary with every element in it. 
It will add numbers to the end of each element's name, to help identify the order of each element and prevent things from being overwritten.
It takes in the xml file path as the parameter.

The format the dictionary is in, will be something like:
```
{
  'title1' : {
    'attributes' : {}'
    'text' : 'Lorem Ipsum''
    'children' : {}
  }'
  'page1' : {
    'attributes' : {
      'background-color' : '#010409''
      'text-color' : '#6495ed''
      'children' : {
        'paragraph1' : {
          'attributes' : {}'
          'text' : '"He who has enough courage and patience to stare into the darkness for his entire life, shall be the first to see the flash of light." — "Khan", Metro 2033, Dmitry Glukhovsky',
          'children' : {}
        }
      }
    }
  }
}
```
