const fs = require("node:fs");
const path = require("path")
const xml2js = require("xml2js")

async function main() {
    // Load and parse guide.xml
    const guidePath = "./guide.xml";
    const guideData = fs.readFileSync(guidePath, "utf8");
    const parser = new xml2js.Parser();
    const builder = new xml2js.Builder();

    const guide = await parser.parseStringPromise(guideData);

    for (const programme of guide.tv.programme) {
        if (programme.image !== undefined) {
            //console.log(programme.image)
            programme.icon = programme.image.map(e => e.replace("http://", "https://"))
        }
    }

    const updatedGuide = builder.buildObject(guide);
    fs.writeFileSync("./guide_new.xml", updatedGuide, "utf8");
    console.log("Updated guide saved as guide_new.xml");

}

main()
