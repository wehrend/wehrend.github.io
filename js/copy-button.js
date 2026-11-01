function copyCodeToClipboard(button) {
    const container = button.parentElement.querySelector('.hcode-multi-container');

    // 1. Try to find the code cell in a Hugo highlight table (usually the second <td>)
    // 2. If no table, fall back to the standard <code> tag
    const codeCell = container.querySelector('td:last-child code, .chroma td:nth-child(2) code');
    const fallbackCode = container.querySelector('code');

    const targetElement = codeCell || fallbackCode;

    if (!targetElement) {
        console.error('Code element not found');
        return;
    }

    // Modern Clipboard API is preferred over execCommand
    const textToCopy = targetElement.innerText.trim();

    navigator.clipboard.writeText(textToCopy).then(() => {
        button.innerText = 'Copied!';
        button.classList.add('copied');

        setTimeout(() => {
            button.innerText = 'Copy';
            button.classList.remove('copied');
        }, 2000);
    }).catch(err => {
        console.error('Unable to copy', err);
        button.innerText = 'Error';
    });
}