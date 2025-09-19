"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EMPTY_MERKLE_ROOT = exports.MerkleTree = void 0;
// The package `@uma/common` can not be tree-shaken and contains some modules that are not
// compatible with the browser. This is a temporary fix to avoid bundling the whole package
// until we can fix the issue upstream.
var MerkleTree_1 = require("@uma/common/dist/MerkleTree");
Object.defineProperty(exports, "MerkleTree", { enumerable: true, get: function () { return MerkleTree_1.MerkleTree; } });
Object.defineProperty(exports, "EMPTY_MERKLE_ROOT", { enumerable: true, get: function () { return MerkleTree_1.EMPTY_MERKLE_ROOT; } });
