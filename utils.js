.pragma library
var fallbackIcon = null;

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
    let flagPaths = getRegionFromString(title);

    if (flagPaths.length === 0 && files && files.get) {
        let firstFile = files.get(0);
        if (firstFile && firstFile.name) {
            flagPaths = getRegionFromString(firstFile.name);
        }
    }

    return flagPaths;
}

function getRegionFromString(text) {
    if (!text || typeof text !== 'string') {
        return [];
    }

    const regionPatterns = [
        {
            id: 'spain',
            patterns: [/Spain/i, /\bES\b/i, /\bSpa\b/i],
            flagFile: "Spain.png",
            priority: 1
        },
        {
            id: 'germany',
            patterns: [/Germany/i, /\bDE\b/i, /\bGer\b/i],
            flagFile: "DE.png",
            priority: 1
        },
        {
            id: 'italy',
            patterns: [/Italy/i, /\bIT\b/i, /\bIta\b/i],
            flagFile: "Ita.png",
            priority: 1
        },
        {
            id: 'usa',
            patterns: [/\bUSA\b/i, /\bUS\b/i, /United States/i],
            flagFile: "USA.png",
            priority: 1
        },
        {
            id: 'japan',
            patterns: [/Japan/i, /\bJPN\b/i, /\bJP\b/i, /\bJ\b(?![a-z])/i],
            flagFile: "Japan.png",
            priority: 1
        },
        {
            id: 'europe',
            patterns: [/Europe/i, /\bEUR\b/i, /\bEU\b/i, /\bE\b(?![a-z])/i],
            flagFile: "Eu.png",
            priority: 2
        },
        {
            id: 'uk',
            patterns: [/\bUK\b/i, /England/i, /Britain/i, /\bGB\b/i],
            flagFile: "uk.png",
            priority: 1
        },
        {
            id: 'france',
            patterns: [/France/i, /\bFR\b/i, /\bFra\b/i],
            flagFile: "Fr.png",
            priority: 1
        },
        {
            id: 'brazil',
            patterns: [/Brazil/i, /\bBR\b/i, /Pt-BR/i],
            flagFile: "BR.png",
            priority: 1
        },
        {
            id: 'netherlands',
            patterns: [/Netherlands/i, /\bNL\b/i, /Dutch/i, /Neerlande/i],
            flagFile: "NL.png",
            priority: 1
        },
        {
            id: 'korea',
            patterns: [/Korea/i, /\bKR\b/i, /\bKOR\b/i],
            flagFile: "Korea.png",
            priority: 1
        },
        {
            id: 'taiwan',
            patterns: [/Taiwan/i, /\bTW\b/i],
            flagFile: "Taiwan.png",
            priority: 1
        },
        {
            id: 'sweden',
            patterns: [/Sweden/i, /\bSE\b/i, /\bSv\b/i],
            flagFile: "Sv.png",
            priority: 1
        },
        {
            id: 'world',
            patterns: [/World/i, /\bW\b(?![a-z])/i, /International/i],
            flagFile: "World.png",
            priority: 4
        }
    ];

    const parenthesisMatches = text.match(/\(([^)]+)\)/g);
    let detectedRegions = [];

    if (parenthesisMatches) {
        parenthesisMatches.forEach(match => {
            const content = match.replace(/[()]/g, '').trim();

            if (content.includes(',')) {
                const parts = content.split(',').map(part => part.trim());
                parts.forEach(part => {
                    checkRegion(part, regionPatterns, detectedRegions, text.indexOf(match));
                });
            } else {
                checkRegion(content, regionPatterns, detectedRegions, text.indexOf(match));
            }
        });
    }

    if (detectedRegions.length > 0) {
        detectedRegions.sort((a, b) => a.position - b.position);

        let flagPaths = [];
        let addedFlags = new Set();

        for (let region of detectedRegions) {
            if (flagPaths.length >= 8) break;

            if (!addedFlags.has(region.flagFile)) {
                flagPaths.push("assets/images/flags/" + region.flagFile);
                addedFlags.add(region.flagFile);
            }
        }

        return flagPaths;
    }

    return [];
}

function checkRegion(text, regionPatterns, detectedRegions, position) {
    for (let region of regionPatterns) {
        for (let pattern of region.patterns) {
            if (pattern.test(text)) {
                if (!detectedRegions.some(r => r.id === region.id)) {
                    detectedRegions.push({
                        id: region.id,
                        flagFile: region.flagFile,
                        priority: region.priority,
                        position: position
                    });
                }
                return;
            }
        }
    }
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

function getGameCollectionShortName(gameData) {
    if (!gameData) return "";

    if (gameData.collection && gameData.collection.shortName) {
        return gameData.collection.shortName;
    }

    if (gameData.collections && gameData.collections.count > 0) {

        for (var i = 0; i < gameData.collections.count; i++) {
            var collection = gameData.collections.get(i);

            if (collection && collection.shortName) {
                return collection.shortName;
            }
        }
    }

    if (gameData.systemShortName) {
        return gameData.systemShortName;
    }

    if (gameData.extra && gameData.extra.collectionShortName) {
        return gameData.extra.collectionShortName;
    }

    console.log("No shortName found for game:", gameData.title);
    return "";
}

function getSystemImagePath(shortName) {
    if (!shortName || shortName === "") return "";
    return "assets/images/systems/" + shortName.toLowerCase() + ".png";
}

function shouldShowSystemIcon(currentCollectionShortName) {
    if (!currentCollectionShortName) {
        return false;
    }

    var shortName = currentCollectionShortName.toLowerCase();
    var shouldShow = shortName === "history" || shortName === "favorites" || shortName === "favorite";

    return shouldShow;
}

function getRandomPixlOSIcon() {
    var totalIcons = 13;
    var randomIndex = Math.floor(Math.random() * totalIcons);
    var iconPath = "assets/images/PIXL-OS/icon_" + randomIndex + ".png";
    return iconPath;
}

function getCollectionIcon(collectionName) {
    if (!collectionName) return getRandomPixlOSIcon();
    var hash = 0;
    for (var i = 0; i < collectionName.length; i++) {
        hash = collectionName.charCodeAt(i) + ((hash << 5) - hash);
    }

    var totalIcons = 13;
    var iconIndex = Math.abs(hash) % totalIcons;
    var iconPath = "assets/images/PIXL-OS/icon_" + iconIndex + ".png";
    return iconPath;
}

function getFallbackPixlOSIcon() {
    if (fallbackIcon !== null) {
        return fallbackIcon;
    }

    var totalIcons = 13;
    var randomIndex = Math.floor(Math.random() * totalIcons);
    fallbackIcon = "assets/images/PIXL-OS/icon_" + randomIndex + ".png";
    return fallbackIcon;
}
