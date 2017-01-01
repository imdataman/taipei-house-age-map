var fs = require("fs");

fs.readFile("tp-projection.json", "utf8", function (error, data) {
  data = JSON.parse(data);
  var result = [],
    items = data.features,
    loopCount = items.length,
    town = "",
    item = {},
    i = 0;
  for (; i < loopCount; i++) {
    item = items[i];
    town = item.properties.TOWN;
    if (result.indexOf(town) === -1) {
      result.push(town);
    }
  }
  console.log(result);

  result.forEach(function (town) {
    var townData = data.features.filter(function (d) {
      return d.properties.TOWN == town;
    });
    townData = JSON.stringify(townData);
    fs.writeFile(`data/${town}.json`, townData, (err) => {
      if (err) throw err;
      console.log('It\'s saved!');
    });
  })
});
