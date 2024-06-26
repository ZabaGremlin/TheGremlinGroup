// Animated rainbow border
function createRainbowBorder() {
    const rainbow = document.createElement('div');
    rainbow.classList.add('rainbow-border');
    document.body.prepend(rainbow);
    
    let hue = 0;
    setInterval(() => {
        hue = (hue + 1) % 360;
        rainbow.style.background = `linear-gradient(90deg, 
            hsl(${hue}, 100%, 50%), 
            hsl(${(hue + 60) % 360}, 100%, 50%), 
            hsl(${(hue + 120) % 360}, 100%, 50%), 
            hsl(${(hue + 180) % 360}, 100%, 50%), 
            hsl(${(hue + 240) % 360}, 100%, 50%), 
            hsl(${(hue + 300) % 360}, 100%, 50%)
        )`;
    }, 50);
}

// Daily Gremlin Tip
const tips = [
    "Always feed your gremlin after midnight for extra fun!\nThe Gremlin Group is not responsible for any damages to your persons or property.",
    "Gremlins love water, be sure to bathe them regularly!\nThe Gremlin Group is not responsible for any damages caused by additional Gremlin spawn.",
    "Train your gremlin to do your taxes.\nThe Gremlin Group is not responsible for any damages to your personal finances.",
    "Remember Gremlin's to keep your Gremlin out of direct sunlight.\nThe Gremlin Group will hold you responsible for any damages to your Gremlin.",
    "For a unique gift idea, send your loved ones a gremlin!\nThe Gremlin Group is not responsible for any damages to your personal relationships."
];

function updateDailyTip() {
    const tipElement = document.getElementById('tip-content');
    const randomTip = tips[Math.floor(Math.random() * tips.length)];
    tipElement.textContent = randomTip;
}

// Easter Egg: Hidden Gremlin
function addHiddenGremlin() {
    const gremlin = document.createElement('div');
    gremlin.id = 'hidden-gremlin';
    gremlin.style.position = 'fixed';
    gremlin.style.bottom = '-50px';
    gremlin.style.right = '20px';
    gremlin.style.width = '50px';
    gremlin.style.height = '50px';
    gremlin.style.background = 'url(/images/gremlin-icon.png) no-repeat';
    gremlin.style.backgroundSize = 'contain';
    gremlin.style.transition = 'bottom 0.3s';
    document.body.appendChild(gremlin);

    document.addEventListener('mousemove', (e) => {
        if (e.clientY > window.innerHeight - 100) {
            gremlin.style.bottom = '0';
        } else {
            gremlin.style.bottom = '-50px';
        }
    });
}

// Initialize everything when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    createRainbowBorder();
    updateDailyTip();
    addHiddenGremlin();

    // Update tip every day (or every page load for demo purposes)
    setInterval(updateDailyTip, 86400000); // 24 hours
});
