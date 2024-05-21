let isDragging = false;
let lastMouseX = 0;
let rotation = 0;

document.addEventListener('mousedown', (e) => {
    isDragging = true;
    lastMouseX = e.clientX;
});

document.addEventListener('mouseup', () => {
    isDragging = false;
});

document.addEventListener('mousemove', (e) => {
    if (isDragging) {
        let deltaX = e.clientX - lastMouseX;
        rotation += deltaX * 0.1;
        lastMouseX = e.clientX;
        fetch(`https://${GetParentResourceName()}/rotate`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify({ rotation: rotation })
        });
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' || e.key === 'Backspace') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            }
        });
    }
});

window.addEventListener('message', (event) => {
    if (event.data.type === 'display') {
        document.body.style.display = 'flex';
    } else if (event.data.type === 'hide') {
        document.body.style.display = 'none';
    }
});


document.addEventListener('keydown', (e) => {
    let step = 1; // Step size for movement
    let direction;
    switch(e.key) {
        case 'w':
            direction = 'up';
            break;
        case 's':
            direction = 'down';
            break;
        case 'ArrowUp':
            direction = 'forward';
            break;
        case 'ArrowDown':
            direction = 'backward';
            break;
        case 'ArrowLeft':
            direction = 'left';
            break;
        case 'ArrowRight':
            direction = 'right';
            break;
        default:
            return; // Ignore other keys
    }

    fetch(`https://${GetParentResourceName()}/move`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ direction: direction })
    });
});
