AEM DEV Tools
=============

Small repo containing some tools I have developed over time as an AEM consultant

Layout
------

I typically have a root `/_data/AEM` containing all my AEM instances. This typically looks like this:

    /_data/AEM
     |- _dist       # directory holding AEM binaries and licences
     |- aem.conf    # base aem.conf used by 'aem' script
     |- bin         # bin directory included in my shell path
     |- 5.6.1       # vanilla 5.6.1 instances
     |- 6.1         # vanilla 6.1 instances
     |- 6.2         # vanilla 6.2 instances
     |- 6.3         # vanilla 6.3 instances
     |- client1     # client specific project instances
     |- client2
     `- client3

For example

    /_data/AEM/6.2
     |- dynamicmedia
     | |- aem.conf
     | |- authorsp1cfp1assetsfp2
     | |- ga
     | |- gaassetsfp2
     | |- sp1
     | |- sp1assetsfp2
     | `- sp1cfp1
     `- vanilla
       |- aem.conf
       |- authorsp1assetsfp2
       |- authorsp1cfp1assetsfp2
       |- authorsp1cfp2assetsfp2
       |- ga
       |- sp1
       |- sp1assetsfp2
       |- sp1cfp1
       |- sp1cfp2
       |- sso
       |- temp
       `- test

`aem` script
------------

This *Bash* script is what I use to create all my local aem instances. It can be run from any directory, and it will search parent directories until it finds an `aem.conf` file

    brobertson@BROBERTSON /_data/AEM/6.2/vanilla/sp1assetsfp2/crx-quickstart/logs
    $ aem
    Searching for aem.conf in /_data/AEM/6.2/vanilla/sp1assetsfp2/crx-quickstart/logs
    Searching for aem.conf in /_data/AEM/6.2/vanilla/sp1assetsfp2/crx-quickstart
    Searching for aem.conf in /_data/AEM/6.2/vanilla/sp1assetsfp2
    Searching for aem.conf in /_data/AEM/6.2/vanilla

    BASE DIR : /_data/AEM/6.2/vanilla


I use Windows and run this from a Cygwin environment. There are currently 2 specific things for this:
* Opening logs uses [Baretail](https://www.baremetalsoft.com/baretail/)
* Opening in browser uses `cygstart` to open URLs in default Windows way

### `aem.conf`

Example:
```
    AEM_JAR=/_data/AEM/_dist/6.2/cq-quickstart-6.2.0.jar
    AEM_LICENSE=/_data/AEM/_dist/6.1/license.properties
    AEM_RUNMODES="vanilla,local"

    LOG_FILES=(error.log stdout.log replication.log)

    AEM_INSTANCES=(author publish sso ga gacameraraw sp1 sp1cfp1 sp1cfp2 sp1assetsfp2 authorsp1assetsfp2 authorsp1cfp1assetsfp2 authorsp1cfp2assetsfp2)

    author_MODE="author"
    author_HOST="author.vanilla.local"
    author_PORT="62200"

    ga_MODE="author"
    ga_HOST="author.ga.local"
    ga_PORT="62201"

    ....
```

This script is just sourced by the [`aem`](bin/aem) script, defining some global variables and specific variables for each aem instance.

_Check the start of the `aem` script - it defines default values for these variables_

- **AEM_JAR**       : the path to the original AEM jar to unpack and use
- **AEM_LICENSE**   : the aem license file to use
- **AEM_RUNMODES**  : runmodes to apply to ALL aem instances in this folder when they start up
- **AEM_JVM_OPTS**  : JVM options to pass to java when starting AEM
- **LOG_FILES**     : list of log files to open
- **AEM_INSTANCES** : list of AEM instances names to consider valid in this folder (lowercase alphanumeric only used/tested)

- **`<instancename>`_MODE** : list of extra modes for this AEM instances - minimum "author" or "publish"
- **`<instancename>`_HOST** : hostname for this instance. I create a bunch of hostnames pointing to 127.0.0.1 in HOSTS file to avoid cookie clashes with different instances using `localhost`. You could also use `*.lvh.me`. See [google](https://www.google.com/search?q=lvh.me)
- **`<instancename>`_PORT** : TCP port to start AEM on. Also used as debug port suffix. Come up with a numbering scheme that works for you to avoid clashes between instances that are commonly running at the same time.


### Commands

Arguments to `aem` are divided up into **operations** and **instances** to perform the operations on. You can specify these in any order.

#### Operations
- **start**      : start aem
- **stop**       : stop aem
- **clean**      : delete the `crx-quickstart` folder
- **unpack**     : Unpack but do not start the AEM instance - used when you need to add `crx-quickstart/install` folder for repository configuration etc
- **compact**    : oak-run compaction (currently user specifies oak version)
- **jps**        : run `$JAVA_HOME/jps` to see running java instances (for this JDK instance)
- **logs**       : open logs
- **urls**       : show urls (inc port number)
- **browser**    : open urls in browser (after confirming AEM is running)
- **open**       : alias for `browser`
- **testuser**   : authentication check - attempt to login to AEM using a specific account (prompted for account)
- **conf**       : print the current applicable `aem.conf` or ask to create one if none found

#### Instances

- **all**      : special instance name to match all instances listed in `AEM_INSTANCES`

### Examples

    $ aem start all
    $ aem stop all
    $ aem author start open
    $ aem jps
    $ aem ga urls


`repo` script
-------------
Repo Tool, copied from this GitHub repo into my repo for ease of checkout

See: https://github.com/Adobe-Marketing-Cloud/tools/tree/master/repo

`jcr-dump.sh`
-------------

Uses [AEM ACS Commons JCR Compare](https://adobe-consulting-services.github.io/acs-aem-commons/features/jcr-compare/index.html) to create a JSON dump for the passed path on the passed server.

    $ jcr-dump.sh http://localhost:4502 admin admin /content/whatever

`jcr-hashes.sh`
-------------

Uses [AEM ACS Commons JCR Compare](https://adobe-consulting-services.github.io/acs-aem-commons/features/jcr-compare/index.html) to create a hash for the passed path on the passed server.

    $ jcr-hashes.sh http://localhost:4502 admin admin /content/whatever

`json-flatten.js`
-----------------

Take a JSON file and flatten it to Key Value pairs to make it easier to diff.

Input sample.json:

    {
      "one": "My string Value One",
      "sub": {
        "one": "My other string value",
        "three": "Another string value three",
        "two": [
          "sub array item 1",
          "sub array item 2"
        ],
        "thirty": 30
      },
      "three": "string",
      "two": [
        "array item 1",
        "array item 2"
      ]
    }

Output:

    $ json-flatten.js sample.json
    /one="My string Value One"
    /sub/one="My other string value"
    /sub/three="Another string value three"
    /sub/two/0="sub array item 1"
    /sub/two/1="sub array item 2"
    /sub/thirty=30
    /three="string"
    /two/0="array item 1"
    /two/1="array item 2"


`json-diff.sh`
-------------

Take 2 JSON files and show the diff of them (uses `json-flatten.js`)

    $ json-diff.sh sample.json sample2.json
    ++ /_data/AEM/bin/json-flatten.js sample.json
    + diff --color=auto -u /dev/fd/63 /dev/fd/62
    ++ /_data/AEM/bin/json-flatten.js sample2.json
    --- /dev/fd/63  2018-07-18 11:01:52.000000000 +0200
    +++ /dev/fd/62  2018-07-18 11:01:52.000000000 +0200
    @@ -1,9 +1,10 @@
     /one="My string Value One"
     /sub/one="My other string value"
    -/sub/three="Another string value three"
    +/sub/three="A modified string value three"
     /sub/two/0="sub array item 1"
     /sub/two/1="sub array item 2"
     /sub/thirty=30
     /three="string"
     /two/0="array item 1"
     /two/1="array item 2"
    +/two/2="extra array item 3"

# License
[MIT License](LICENSE)
