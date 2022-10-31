const fs = require("fs");
const path = require("path");

const write = (data) => {
  fs.writeFileSync(
    path.join(__dirname, `merkle.json`),
    JSON.stringify(data, null, 2)
  );
};

module.exports = { write };
