const fs = require('fs');
const langPath = "Northstar.Client/mod/resource";
const knownLanguages = ['english', 'french', 'german', 'italian', 'japanese', 'mspanish', 'portuguese', 'russian', 'spanish', 'tchinese'];

// Get language files names
const langs = fs.readdirSync(langPath)
    .filter(lang => lang.indexOf('northstar_client_localisation_') !== -1);


function getLanguageKeys (lang) {
    if (knownLanguages.indexOf(lang) === -1) return;
    return fs.readFileSync(`${langPath}/northstar_client_localisation_${lang}.txt`, {encoding:'utf16le', flag:'r'})
        .split('\n')
        .filter(line => line.length !== 0)  // remove empty lines
        // keep only lines with translation keys
        .filter(line => {
            const words = line.split('" "');
            return words.length === 2 && words[1] !== 'english"'
        })
        .map(line => line.replaceAll('\t', '')) // remove tabs characters
        .map(line => line.split('" "')[0].substring(1)); // only keep translation keys (throw values)
}

// We use english keys as reference for other languages
const englishKeys = getLanguageKeys('english');
knownLanguages.shift();

// Check for each language if there are missing keys
for (const language of knownLanguages) {
    const languageKeys = getLanguageKeys(language);
    const missingKeys = [...englishKeys] // clone
        .filter(key => languageKeys.indexOf(key) === -1);
    const missingKeysLength = missingKeys.length;
    console.log(
        missingKeysLength === 0 
        ? `"${language}" doesn't have missing keys.`
        : `"${language}" has ${missingKeys.length} missing keys.`
    );
    if (missingKeysLength !== 0)
        console.log(missingKeys);
}