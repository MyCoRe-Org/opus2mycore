# OPUS to MyCoRe [![Build Status](https://travis-ci.org/MyCoRe-Org/opus2mycore.svg?branch=master)](https://travis-ci.org/MyCoRe-Org/opus2mycore) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/39b52bf6dd0c4130a7e003ffee4336bf)](https://www.codacy.com/app/MyCoRe/opus2mycore?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=MyCoRe-Org/opus2mycore&amp;utm_campaign=Badge_Grade)

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

* **-sfc, --skipFormatCheck**<br />
  *Default:* `false`<br />
  
  Skips the check if OAI metadata format is listed.
    
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

