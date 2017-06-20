'use babel';
import fs from 'fs-extra';

const writeFile = (path, contents) =>
  new Promise((resolve, reject) => {
    fs.writeFile(path, contents, err => (err ? reject(err) : resolve()));
  });

export default writeFile;
