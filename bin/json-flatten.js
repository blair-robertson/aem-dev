#!/usr/bin/env node

//########################################################################################
//# MIT License                                                                          #
//#                                                                                      #
//# Copyright (c) Blair Robertson 2018                                                   #
//#                                                                                      #
//# Permission is hereby granted, free of charge, to any person obtaining a copy         #
//# of this software and associated documentation files (the "Software"), to deal        #
//# in the Software without restriction, including without limitation the rights         #
//# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell            #
//# copies of the Software, and to permit persons to whom the Software is                #
//# furnished to do so, subject to the following conditions:                             #
//#                                                                                      #
//# The above copyright notice and this permission notice shall be included in all       #
//# copies or substantial portions of the Software.                                      #
//#                                                                                      #
//# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR           #
//# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,             #
//# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE          #
//# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER               #
//# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,        #
//# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE        #
//# SOFTWARE.                                                                            #
//########################################################################################


// Take a JSON file as imput and product a flat Key>Value version that can be used for checking differences

const fs = require('fs');
const util = require('util');

const NODE_PATH    = process.argv[0];
const SCRIPT_PATH  = process.argv[1];

// my actual arguments
const JSON_FILE = process.argv[2];

fs.accessSync(JSON_FILE, fs.constants.R_OK);

var json = JSON.parse(fs.readFileSync(JSON_FILE, 'utf8'));

function flattenJson(jsonObj, parentPath) {
	for (var key in jsonObj) {
		var currentPath = parentPath + "/" + key;
		if (typeof jsonObj[key] == "object") {
			flattenJson(jsonObj[key], currentPath);
		}
		else {
			console.log(currentPath + "=" + JSON.stringify(jsonObj[key]));
		}
	}
	
}

flattenJson(json, "");