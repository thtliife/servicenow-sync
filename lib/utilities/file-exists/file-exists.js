'use babel';
import fs from 'fs-extra';

const fileExists = path =>
  new Promise((resolve, reject) => {
    fs.access(path, err => {
      if (err) {
        if (err.code === 'ENOENT') {
          resolve(false);
        }
        reject(err);
      }
      resolve(true);
    });
  });

export default fileExists;
