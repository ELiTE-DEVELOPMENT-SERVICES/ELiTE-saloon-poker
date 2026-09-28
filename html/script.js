const resourceName = window.GetParentResourceName ? GetParentResourceName() : 'saloon-poker';

function post(endpoint, data) {
    return fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {})
    });
}

const app = document.getElementById('app');
const balanceEl = document.getElementById('balance');
const currentBetEl = document.getElementById('currentBet');
const betPanel = document.getElementById('betPanel');
const actionPanel = document.getElementById('actionPanel');
const betInput = document.getElementById('betInput');
const resultBanner = document.getElementById('resultBanner');
const dealerCardsEl = document.getElementById('dealerCards');
const playerCardsEl = document.getElementById('playerCards');
const dealerTotalEl = document.getElementById('dealerTotal');
const playerTotalEl = document.getElementById('playerTotal');

const suitSymbols = { hearts: '♥', diamonds: '♦', clubs: '♣', spades: '♠' };

function renderCard(card) {
    const div = document.createElement('div');
    if (card.hidden) {
        div.className = 'card card-back';
        return div;
    }
    const red = card.suit === 'hearts' || card.suit === 'diamonds';
    div.className = 'card' + (red ? ' red' : ' black');
    div.textContent = `${card.rank}${suitSymbols[card.suit]}`;
    return div;
}

function renderHand(container, hand) {
    container.innerHTML = '';
    hand.forEach(c => container.appendChild(renderCard(c)));
}

window.addEventListener('message', (event) => {
    const data = event.data;
    switch (data.action) {
        case 'open':
            app.classList.remove('hidden');
            betInput.min = data.minBet;
            betInput.max = data.maxBet;
            betPanel.classList.remove('hidden');
            actionPanel.classList.add('hidden');
            resultBanner.classList.add('hidden');
            dealerCardsEl.innerHTML = '';
            playerCardsEl.innerHTML = '';
            dealerTotalEl.textContent = '';
            playerTotalEl.textContent = '';
            break;
        case 'close':
            app.classList.add('hidden');
            break;
        case 'balance':
            balanceEl.textContent = data.amount;
            break;
        case 'state': {
            const s = data.state;
            currentBetEl.textContent = s.bet;
            renderHand(playerCardsEl, s.playerHand);
            renderHand(dealerCardsEl, s.dealerHand);
            playerTotalEl.textContent = `(${s.playerTotal})`;
            dealerTotalEl.textContent = s.dealerTotal ? `(${s.dealerTotal})` : '';
            if (s.state === 'playing') {
                betPanel.classList.add('hidden');
                actionPanel.classList.remove('hidden');
            } else {
                actionPanel.classList.add('hidden');
            }
            break;
        }
        case 'result': {
            resultBanner.classList.remove('hidden');
            resultBanner.className = 'banner ' + data.result.outcome;
            const messages = {
                win: `You win $${data.result.payout}!`,
                blackjack: `Blackjack! You win $${data.result.payout}!`,
                lose: 'Dealer wins.',
                bust: 'Bust! You lose.',
                push: 'Push — bet returned.',
                error: data.result.message
            };
            resultBanner.textContent = messages[data.result.outcome] || '';
            setTimeout(() => {
                resultBanner.classList.add('hidden');
                betPanel.classList.remove('hidden');
            }, 2500);
            break;
        }
    }
});

document.getElementById('placeBetBtn').addEventListener('click', () => {
    const amount = parseInt(betInput.value, 10);
    post('placeBet', { amount });
});
document.getElementById('hitBtn').addEventListener('click', () => post('hit'));
document.getElementById('standBtn').addEventListener('click', () => post('stand'));
document.getElementById('doubleBtn').addEventListener('click', () => post('double'));
document.getElementById('closeBtn').addEventListener('click', () => post('close'));

document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') post('close');
});
