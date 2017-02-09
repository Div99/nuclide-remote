'use strict';

const https = require('https');
const fs = require('fs');

function updateDockerfile(tag) {
  const file = './Dockerfile';
  fs.readFile(file, 'utf8', (err, data) => {
    if (err) {
      return console.log(err);
    }
    data = data.replace(/^ENV\s*IMAGE_NUCLIDE_VERSION=*.*\\$/gm, `ENV IMAGE_NUCLIDE_VERSION=${tag.substr(1)} \\`);
    fs.writeFile(file, data, 'utf8');
  });
}

function getLatestNuclideTag(callback) {
  let options = {
    hostname: 'api.github.com',
    port: 443,
    path: '/repos/facebook/nuclide/tags',
    method: 'GET',
    headers: {
      'user-agent': "This-is-a-valid-agent-for-GitHub-API"
    }
  };

  if (process.env.GH_OAUTH_TOKEN && process.env.GH_OAUTH_TOKEN.length > 0) {
    options.headers.Authorization = `token ${process.env.GH_OAUTH_TOKEN}`;
  }

  return https.request(options, res => {
    // Consume data from the stream
    var response = '';
    res.on('data', (d) => {
      response += d;
    });

    // Once all the data in the stream has been consumed
    res.on('end', () => {
      try {
        const latestTag = JSON.parse(response).map(t => t.name).sort().reverse()[0];

        // If the tag is stable, update dockerfile
        if (Array.isArray(latestTag.match(/^((?!rc).)*$/))) {
          callback(latestTag);
        }
      } catch (e) {
        throw new Error(e)
      }
    });
  }).on('error', e => {
    // Do nothing
  }).end();
}

getLatestNuclideTag(updateDockerfile);
