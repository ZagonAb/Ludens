.pragma library

function cleanGameTitle(title) {
    if (!title || typeof title !== 'string') {
        return title || '';
    }

    const patterns = [
        /\s*\([^)]*(?:USA|NGM|Euro|Europe|Japan|World|Japan, USA|Korea|Asia|Brazil|Germany|France|Italy|Spain|UK|Australia|Canada|rev|sitdown|set|Hispanic|China|Ver|ver|US|68k|bootleg|Nintendo|Taiwan|Hong Kong|Latin America|Mexico|Russia|Sweden|Netherlands|Belgium|Portugal|Greece|Finland|Norway|Denmark|Poland|Czech|Slovak|Hungary|Romania|Bulgaria|Croatia|Serbia|Turkey|Israel|UAE|Saudi Arabia|South Africa|Egypt|Philippines|Indonesia|Malaysia|Singapore|Thailand|Vietnam)[^)]*\)/gi,
        /\s*\([^)]*(?:Rev \d+|Version \d+|v\d+\.\d+|Update \d+|Beta|Alpha|Demo|Prototype|Unl|Sample|Preview|Trial)[^)]*\)/gi,
        /\s*\([^)]*(?:NES|SNES|N64|GC|Wii|Switch|GB|GBC|GBA|DS|3DS|PS1|PS2|PS3|PS4|PS5|PSP|Vita|Xbox|Xbox 360|Xbox One|Genesis|Mega Drive|Saturn|Dreamcast|Arcade|MAME|FBA|Neo Geo)[^)]*\)/gi,
        /\s*-\s*(?:USA|EUR|JPN|KOR|ASI|BRA|GER|FRA|ITA|SPA|UK|AUS|CAN|CHN|TWN|HKG|LAT|MEX|RUS)[\s\-]*/gi,
        /\s*\[[^\]]*(?:Rev \d+|v\d+\.\d+)[^\]]*\]/gi,
        /\s*\[[^\]]*(?:Good|Bad|Overdump|Underdump|Verified|Trurip|No-Intro|Redump)[^\]]*\]/gi,
        /\s*\[[^\]]*(?:Crack|Trainer|Cheat|Hack|Patch|Fixed|Translated)[^\]]*\]/gi,
        /\s*\[[^\]]*(?:!\?|!\s*|\(\?\))[^\]]*\]/gi,
        /\s*\(Disk \d+ of \d+\)/gi,
        /\s*\(Side [A-B]\)/gi,
        /\s*\(Track \d+\)/gi,
        /\s*\([\d\s]+in[\d\s]+\)/gi,
        /\s*\(\d{4}[-\.]\d{2}[-\.]\d{2}\)/
        ];

        let cleanedTitle = title;

        patterns.forEach(pattern => {
            cleanedTitle = cleanedTitle.replace(pattern, '');
        });

        cleanedTitle = cleanedTitle
        .replace(/^\s+|\s+$/g, '')
        .replace(/\s{2,}/g, ' ')
        .replace(/^[-\s]+|[-\s]+$/g, '')
        .replace(/,\s*$/, '')
        .replace(/\.\s*$/, '');

        if (!cleanedTitle || cleanedTitle.trim() === '') {
            return title.trim();
        }

        return cleanedTitle.trim();
}

function getRegionFlag(title, files) {
    let flagVariants = getRegionFromString(title);

    if (flagVariants.length === 0 && files && files.get) {
        let firstFile = files.get(0);
        if (firstFile && firstFile.name) {
            flagVariants = getRegionFromString(firstFile.name);
        }
    }

    return flagVariants;
}

function getRegionFromString(text) {
    if (!text || typeof text !== 'string') {
        return [];
    }

    const regionPatterns = [
        {
            id: 'spain',
            patterns: [/^Spain$/i, /^ES$/i, /^Es$/i, /^Spa$/i],
            flagVariants: ["Spain","Es", "ES", "Spa", "spain", "es", "spa"],
            priority: 1
        },
        {
            id: 'germany',
            patterns: [/^Germany$/i, /^DE$/i, /^De$/i, /^Ger$/i],
            flagVariants: ["Germany", "DE", "Ger", "De", "germany", "de", "ger"],
            priority: 1
        },
        {
            id: 'italy',
            patterns: [/^Italy$/i, /^IT$/i, /^It$/i],
            flagVariants: ["Italy", "IT", "It", "italy", "it", "Ita"],
            priority: 1
        },
        {
            id: 'usa',
            patterns: [/^USA$/i, /^US$/i, /^U\.S\.A\.$/i, /^United States$/i],
            flagVariants: ["USA", "US", "Usa", "usa", "us", "United States", "united states"],
            priority: 1
        },
        {
            id: 'japan',
            patterns: [/^Japan$/i, /^JPN$/i, /^JP$/i, /^J$/i, /^Ja$/i],
            flagVariants: ["Japan", "JPN", "JP", "J", "Ja", "japan", "jpn", "jp", "j", "ja"],
            priority: 1
        },
        {
            id: 'europe',
            patterns: [/^Europe$/i, /^EUR$/i, /^EU$/i, /^E$/i],
            flagVariants: ["Europe", "EUR", "EU", "E", "europe", "eur", "eu", "e", "Eu"],
            priority: 2
        },
        {
            id: 'uk',
            patterns: [/^UK$/i, /^England$/i, /^Britain$/i, /^GB$/i, /^En$/i],
            flagVariants: ["England", "Britain", "GB", "En", "uk", "england", "britain", "gb", "en"],
            priority: 1
        },
        {
            id: 'france',
            patterns: [/^France$/i, /^FR$/i, /^Fr$/i],
            flagVariants: ["France", "FR", "Fr", "france", "fr"],
            priority: 1
        },
        {
            id: 'brazil',
            patterns: [/^Brazil$/i, /^BR$/i, /^Pt-BR$/i],
            flagVariants: ["Brazil", "BR", "Brazil", "br", "brazil"],
            priority: 1
        },
        {
            id: 'netherlands',
            patterns: [/^Netherlands$/i, /^NL$/i, /^Nl$/i, /^NLD$/i, /^Dutch$/i, /^Neerland(e|é)s$/i],
            flagVariants: ["Netherlands", "NL", "Nl", "NLD", "Dutch", "Neerlandes", "netherlands", "nl", "nld", "dutch", "neerlandes"],
            priority: 1
        },
        {
            id: 'pal',
            patterns: [/^PAL$/i],
            flagVariants: ["PAL", "pal"],
            priority: 3
        },
        {
            id: 'world',
            patterns: [/^World$/i, /^W$/i, /^All$/i, /^Intl$/i, /^International$/i, /^Global$/i],
            flagVariants: ["World", "W", "All", "Intl", "International", "Global", "world", "w", "all", "intl", "international", "global"],
            priority: 4
        }
    ];

    const parenthesisMatches = text.match(/\(([^)]+)\)/g);
    let detectedRegions = [];

    if (parenthesisMatches) {
        parenthesisMatches.forEach(match => {
            const content = match.replace(/[()]/g, '').trim();
            const hasCommas = content.includes(',');
            if (hasCommas) {
                const parts = content.split(',').map(part => part.trim());
                parts.forEach(part => {
                    for (let region of regionPatterns) {
                        for (let pattern of region.patterns) {
                            if (pattern.test(part)) {
                                if (!detectedRegions.some(r => r.flagVariants[0] === region.flagVariants[0])) {
                                    detectedRegions.push({
                                        flagVariants: region.flagVariants,
                                        priority: region.priority,
                                        position: text.indexOf(match)
                                    });
                                }
                                break;
                            }
                        }
                    }
                });
            } else {
                for (let region of regionPatterns) {
                    for (let pattern of region.patterns) {
                        if (pattern.test(content)) {
                            if (!detectedRegions.some(r => r.flagVariants[0] === region.flagVariants[0])) {
                                detectedRegions.push({
                                    flagVariants: region.flagVariants,
                                    priority: region.priority,
                                    position: text.indexOf(match)
                                });
                            }
                            break;
                        }
                    }
                }
            }
        });
    }

    if (detectedRegions.length > 0) {
        detectedRegions.sort((a, b) => a.position - b.position);

        let flagPaths = [];
        for (let region of detectedRegions.slice(0, 8)) {
            for (let variant of region.flagVariants) {
                flagPaths.push("assets/images/flags/" + variant + ".png");
            }
        }
        return flagPaths;
    }

    return [];
}

function isFavorite(game) {
    return game && game.favorite === true;
}

function formatPlayCount(playCount) {
    if (!playCount || playCount === 0) {
        return '';
    }
    return playCount + (playCount === 1 ? ' play' : ' plays');
}

function formatReleaseYear(releaseYear) {
    if (!releaseYear || releaseYear <= 0) {
        return '';
    }
    return releaseYear.toString();
}


function getUniqueGenresFromGames(maxGenres) {
    var uniqueGenres = new Set();
    var genreCount = {};

    for (var i = 0; i < api.allGames.count; i++) {
        var game = api.allGames.get(i);
        if (game && game.genre) {
            var cleanedGenres = cleanAndSplitGenres(game.genre);
            cleanedGenres.forEach(function(genre) {
                if (genre && genre.trim() !== "") {
                    var cleanGenre = genre.trim();
                    uniqueGenres.add(cleanGenre);

                    if (!genreCount[cleanGenre]) {
                        genreCount[cleanGenre] = 0;
                    }
                    genreCount[cleanGenre]++;
                }
            });
        }
    }

    var genresArray = Array.from(uniqueGenres);
    genresArray.sort(function(a, b) {
        return (genreCount[b] || 0) - (genreCount[a] || 0);
    });

    if (maxGenres && maxGenres > 0) {
        return genresArray.slice(0, maxGenres);
    }

    return genresArray;
}

function cleanAndSplitGenres(genreText) {
    if (!genreText) return [];

    var separators = [",", "/", "-", "&", "|", ";"];
    var allParts = [genreText];

    for (var i = 0; i < separators.length; i++) {
        var separator = separators[i];
        var newParts = [];

        for (var j = 0; j < allParts.length; j++) {
            var part = allParts[j];
            var splitParts = part.split(separator);

            for (var k = 0; k < splitParts.length; k++) {
                newParts.push(splitParts[k]);
            }
        }
        allParts = newParts;
    }

    var cleanedParts = [];
    for (var l = 0; l < allParts.length; l++) {
        var cleaned = allParts[l].trim();

        if (cleaned.length > 0 &&
            cleaned.toLowerCase() !== "and" &&
            cleaned.toLowerCase() !== "or" &&
            cleaned.toLowerCase() !== "game" &&
            cleaned.length > 2) {
            cleanedParts.push(cleaned);
            }
    }

    return cleanedParts;
}

function getFirstGenre(gameData) {
    if (!gameData || !gameData.genre) return "Unknown";

    var cleanedGenres = cleanAndSplitGenres(gameData.genre);
    return cleanedGenres.length > 0 ? cleanedGenres[0] : "Unknown";
}

function formatDate(dateString) {
    if (!dateString) return "";

    if (typeof dateString === 'string' && dateString.length > 0) {
        return dateString;
    }

}

function formatPlayTime(seconds) {
    if (!seconds || seconds === 0) return "";

    var minutes = Math.floor(seconds / 60);

    if (minutes < 60) {
        return minutes + " min";
    } else {
        var hours = Math.floor(minutes / 60);
        var remainingMinutes = minutes % 60;
        return hours + "h " + (remainingMinutes > 0 ? remainingMinutes + "m" : "");
    }
}

function formatShortDate(dateString) {
    if (!dateString) return "";

    try {
        var date = new Date(dateString);
        if (isNaN(date.getTime())) return dateString;

        var day = date.getDate().toString().padStart(2, '0');
        var month = (date.getMonth() + 1).toString().padStart(2, '0');
        var year = date.getFullYear().toString().slice(-2);

        return day + "/" + month + "/" + year;
    } catch (e) {
        return dateString;
    }
}
