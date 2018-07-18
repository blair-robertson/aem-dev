#!/usr/bin/env node


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
