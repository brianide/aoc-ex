#!/usr/bin/env -S deno run -A

async function exists(path) {
    try {
        await Deno.stat(path);
        return true;
    }
    catch(_) {
        return false;
    }
}

function wait(millis) {
    return new Promise(res => setTimeout(() => res(), millis));
}

const [year, days, mode] = Deno.args;
const cookie = await Deno.readTextFile(".cookie.dat").then(r => r.trim());

// Make directories if they're not already in place
await Deno.mkdir(`lib/Y${year}`, { recursive: true });
await Deno.mkdir(`input/real/${year}`, { recursive: true });

async function getInput(year, day) {
    const dest = `input/real/${year}/day${day}.txt`;
    if (await exists(dest))
        return;
    console.log(`Pulling input for day ${day}`);

    const text = await fetch(`https://adventofcode.com/${year}/day/${day}/input`, {
        headers: {
            Cookie: `session=${cookie}`
        }
    }).then(r => r.text());
    await Deno.writeTextFile(dest, text);
}

if (mode === "input") {
    for (const day of days.split(",").map(n => +n)) {
        // Get problem input
        await getInput(year, day);
        await wait(1500);
    }
    Deno.exit(0);
}

for (const day of days.split(",").map(n => +n)) {
    // Get problem name
    const url = `https://adventofcode.com/${year}/day/${day}`;
    const page = await fetch(url).then(r => r.text());
    const name = /<h2>--- Day \d+: (.+) ---<\/h2>/.exec(page)[1];
    console.log(`Getting problem name`);

    // Make solution file
    const fileText = (await Deno.readTextFile("day_template.exs")).replace(/![A-Z]+?!/g, k => {
        return { year, day, name }[k.slice(1, -1).toLowerCase()];
    });
    await Deno.writeTextFile(`lib/Y${year}/day${day}.ex`, fileText);
    console.log(`Making file for solution`);

    // Add module to index
    const projText = (await Deno.readTextFile(`lib/Y${year}/index.ex`)).split("\n");
    projText.splice(projText.findIndex(l => l.includes("## NEXT ##")), 0, `    {AOC.Y${year}.Day${day}, "${name}"},`);
    await Deno.writeTextFile(`lib/Y${year}/index.ex`, projText.join("\n"));
    await wait(1500);
    console.log(`Adding module to index`);

    // Get problem input
    await getInput(year, day);

    await wait(1500);
}
