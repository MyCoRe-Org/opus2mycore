# OPUS to MyCoRe [![Build Status](https://travis-ci.org/MyCoRe-Org/opus2mycore.svg?branch=master)](https://travis-ci.org/MyCoRe-Org/opus2mycore)

 Use this project to extract OPUS records from OAI 2.0 to MyCoRe compatible MODS-Format.
 
## Usage

Run on commandline with:
```shell
java -jar opus2mycore.jar --help
```

### Commandline Options

* **-f, --format**<br />
  *Default:* `xMetaDissPlus`<br />
  
  The OAI metadata format.
  
* **-h, --help**<br />

  Print help (this message) and exit
  
* **-o, --output_dir**<br />
  
  The output directory.

* **--projectId**<br />
  *Default:* `mir`<br />
  
  The MyCoRe procject id. (used for command.txt)

* **-s, --setSpec**<br />

  The OAI metadata set spec.
  
* **--stylesheet**<br />
  
  Path to custom XSL-Stylesheet for transformation.
  
* **-u, --url**<br />
  
  The OAI base URL.

