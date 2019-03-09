# CI/CD for Sphero Edu


## Overview
Although there is no development lifecycle tools for code on the Sphero Edu site, we can create a process using source control and this simple script that wraps a javascript file in the Sphere Edu .lab file and posts it to the remix site. 

Of course, this is just one step. Figuring out how to test your code, linting, code reviews, release process is all up to you. :) 

Before you begin:

    1. Register your account on https://edu.sphero.com. 
       _The script expects a sphero ID, not Google or Clever_  
    2. Create one or more remixes. You can create a remix for dev, test, prod.
    3. Collect your username, password and remix IDs (find them in the URL of your browser). 

### The Script

The script is only tested in bash on Linux. It works in Azure Pipelines with Ubuntu agents. 

Assumes that you are using robot 9, BOLT. The -r option has no impact yet.

```
Deploys javascript to a edu.sphero.com remix

Usage: ./deploy-spheroedu.sh  -f|--file -t|--title --public -u|--username -p|--password -i|--id -r|--robot 

 -f | --file         Optional     The javascript file to deploy
 -t | --title        Optional     Title of the remix
      --public       Optional     Make the remix public
 -u | --username     Required     The email or userid of the edu.sphero.com user
 -p | --password     Required     The password of the edu.sphero.com user
 -i | --id           Required     The remix Id to deploy the javascript code to
 -r | --robot        Optional     Comma seperated list of robots to support
```

Examples:

```
./deploy-spheroedu.sh -u johndoe -p somepassword -i 123456
```
This will assume that the javascript is in code.js and uploads it to _private_ remix 123456.

```
./deploy-spheroedu.sh -u johndoe -p somepassword -i 123456 -f somefile.js --public
```
This loads the code from somefile.js and uploads it to _public_ remix 123456.

### Azure DevOps
    
    1. Create build/release pipeline
    2. Add parameters for username, password, remixid
    3. Set the build agent to Ubuntu
    4. Add a bash task to execute deploy-spheroedu.sh with arguments:
        -u $(username) -p $(somepassword) -i $(remixid) -f code.js


