#!/usr/bin/env node

// MIT License
//
// Copyright (c) Blair Robertson 2018
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Takes the JSON from Package Manager List and produces list of packages that can be deleted because they are old versions
//
// Created because I had to get a copy of a customer AEM instance and it was over 80GB, of which 70GB was /etc/packages#
// 
// Usage: 
//		$ curl -u admin:admin -o package-list.json 'http://localhost:4502/crx/packmgr/list.jsp?_charset_=utf-8&includeVersions=true'
//		$ get-old-packages.js package-list.json > old-packages.txt
//
// Note: you may want to filter the old packages to exclude Product packages
//
// Use CRX PackMgr delete to also delete the corresponding snapshots taken when a package is installed
//		$ for p in `cat old-packages.txt`; do  curl -i -u admin:admin -X POST "http://localhost:4502/crx/packmgr/service/script.json$p?cmd=delete"; done;
//


const fs = require('fs');
const util = require('util');

const NODE_PATH    = process.argv[0];
const SCRIPT_PATH  = process.argv[1];

// my actual arguments
const JSON_FILE = process.argv[2];

fs.accessSync(JSON_FILE, fs.constants.R_OK);

var pkgListJson = JSON.parse(fs.readFileSync(JSON_FILE, 'utf8'));

var pkgs = {};

for (var i = 0; i < pkgListJson.results.length; i++) {
    let pkg = pkgListJson.results[i];
    let pid = pkg.pid;
    let id  = pkg.group + ":" + pkg.name;

    if (! pkgs[id]) {
        pkgs[id] = {"max": pkg.version, "pkgs": [pkg]};
    }
    else {
        if (compareVersion(pkgs[id].max, pkg.version)) {
            pkgs[id].max = pkg.version;
        }
        pkgs[id].pkgs.push(pkg);
    }
}

//console.log(util.inspect(pkgs, false, null))

for (var id in pkgs) {
    
    for (var i = 0; i < pkgs[id].pkgs.length; i++) {
        if (pkgs[id].max !== pkgs[id].pkgs[i].version) {
            console.log(pkgs[id].pkgs[i].path);
        }
    }

}

// taken from /crx/packmgr/js/CRX/packmgr/PackageStore.js
function compareVersion(version1, version2) {
    var a = parseVersion(version1);
    var b = parseVersion(version2);
    
    for (var i = 0, len = Math.min(a.length, b.length); i < len; i++) {
        var s1 = a[i];
        var s2 = b[i];
        var c = s1 < s2 ? -1 : (s1 > s2 ? 1 : 0);
        if (c === 0) {
            continue;
        }
        var v1 = parseInt(s1);
        var v2 = parseInt(s2);
        if (!isNaN(v1) && !isNaN(v2) && v1 != v2) {
            return v1 - v2;
        }
        return c;
    }
    return a.length - b.length;
}

function parseVersion (v) {
    return v.split(/[\.-]+/);
}