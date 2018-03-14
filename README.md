[![Build Status](https://travis-ci.org/sul-dlss/mods_normalizer.svg?branch=master)](https://travis-ci.org/sul-dlss/mods_normalizer)
[![Gem Version](https://badge.fury.io/rb/stanford-mods-normalizer.svg)](https://badge.fury.io/rb/stanford-mods-normalizer)

# Stanford::Mods::Normalizer

Provides methods to normalize MODS XML according to the Stanford guidelines



## Usage:

Normalizing an xml document

```ruby
  require 'stanford/mods/normalizer'
  input_file = 'bb936cg6081.xml' # starting mods document
  output_file = 'bb936cg6081-cleaned.xml' # cleaned up mods document
  mods_xml = File.open(input_file) # read it in
  mods_xml_doc = Nokogiri::XML(mods_xml) # create a nokogiri doc
  normalizer = Stanford::Mods::Normalizer.new
  normalizer.normalize_document(mods_xml_doc.root) # normalize it
  File.write(output_file,mods_xml_doc.to_xml) # write it out
```
