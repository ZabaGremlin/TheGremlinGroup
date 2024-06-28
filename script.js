// Constants
const TIPS = [
    "Always feed your gremlin after midnight for extra fun!*<br><br><small>*The Gremlin Group is not responsible for any damages to your persons or property.</small>",
    "Gremlins love water, be sure to bathe them regularly!*<br><br><small>*The Gremlin Group is not responsible for any damages caused by additional Gremlin spawn.</small>",
    "Train your gremlin to do your taxes.*<br><br><small>*The Gremlin Group is not responsible for any damages to your personal finances.</small>",
    "Remember to keep your Gremlin out of direct sunlight.*<br><br><small>*The Gremlin Group will hold you responsible for any damages to your Gremlin.</small>",
    "For a unique gift idea, send your loved ones a gremlin!*<br><br><small>*The Gremlin Group is not responsible for any damages to your personal relationships.</small>"
];

// Utility functions
const getRandomItem = (array) => array[Math.floor(Math.random() * array.length)];
const setInterval = (callback, delay) => setTimeout(() => { callback(); setInterval(callback, delay); }, delay);

// Rainbow border
function createRainbowBorder() {
    const rainbow = document.createElement('div');
    rainbow.classList.add('rainbow-border');
    document.body.prepend(rainbow);

    let hue = 0;
    setInterval(() => {
        hue = (hue + 1) % 360;
        rainbow.style.background = `linear-gradient(90deg, 
            ${[0, 60, 120, 180, 240, 300].map(offset => `hsl(${(hue + offset) % 360}, 100%, 50%)`).join(', ')})`;
    }, 50);
}

// Modal functionality
function setupModal() {
    const modal = document.createElement('div');
    modal.id = 'myModal';
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-content">
            <span class="close">&times;</span>
            <img src="gremlin-eating-letter.jpg" alt="Gremlin eating a letter" style="max-width: 100%; height: auto;">
            <p>Thank you for your message! The GremlinGroup takes all communications seriously (even the ones our gremlins try to eat).</p>
            <p>We promise to reply within 3-5 business years, or whenever our carrier pigeon learns to read, whichever comes first.</p>
        </div>
    `;
    document.body.appendChild(modal);

    const closeBtn = modal.querySelector(".close");
    closeBtn.onclick = () => modal.style.display = "none";
    window.onclick = (event) => {
        if (event.target == modal) modal.style.display = "none";
    };

    const form = document.getElementById("gremlinForm");
    if (form) {
        form.onsubmit = (event) => {
            event.preventDefault();
            modal.style.display = "block";
        };
    }
}

// Daily Gremlin Tip
function updateDailyTip() {
    const tipElement = document.getElementById('tip-content');
    if (tipElement) tipElement.innerHTML = getRandomItem(TIPS);
}

// Hidden Gremlin
function setupHiddenGremlin() {
    const gremlin = document.createElement('a');
    gremlin.href = 'secret.html';
    gremlin.className = 'hidden-gremlin';
    document.body.appendChild(gremlin);

    function peekGremlin() {
        const position = getRandomItem(['left', 'right', 'top', 'bottom']);
        gremlin.className = `hidden-gremlin ${position}`;
        gremlin.style.backgroundImage = `url(./images/gremlin-icon${position === 'top' || position === 'bottom' ? '2' : ''}.png)`;

        setTimeout(() => {
            gremlin.classList.add(`peek-${position}`);
            setTimeout(() => gremlin.classList.remove(`peek-${position}`), 2000);
        }, 500);

        setTimeout(peekGremlin, Math.random() * 25000 + 5000);
    }

    peekGremlin();
}
// Function to play audio
let audio = new Audio('GremlinBop.mp3');
let isPlaying = false;

function toggleAudio() {
    if (isPlaying) {
        audio.pause();
    } else {
        audio.loop = true;
        audio.play();
    }
    isPlaying = !isPlaying;

    // Toggle the image source
    const image = document.getElementById('BopImage');
    if (image) {
        if (isPlaying) {
            image.src = './images/GremDance.gif';  // Replace 'animated.gif' with your animated gif URL
        } else {
            image.src = './images/GremlinBop.png';  // Replace 'original.jpg' with your original image URL
        }
    }
}

const image = document.getElementById('BopImage');
if (image) {
    image.addEventListener('click', toggleAudio);
}

// Initialize everything when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    createRainbowBorder();
    setupModal();
    updateDailyTip();
    setupHiddenGremlin();
    setInterval(updateDailyTip, 86400000); // Update tip every 24 hours
});