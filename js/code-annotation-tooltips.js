document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll('.hcode-multi-container').forEach(container => {
    const commentStr = container.dataset.comments;
    if (!commentStr) return;

    const actualLines = Array.from(container.querySelectorAll('code > span'))
                             .filter(line => line.textContent.replace(/\s/g, '').length > 0);

    // Filtert leere Segmente aus, falls Semikolons doppelt vorkommen
    commentStr.split(';').map(s => s.trim()).filter(Boolean).forEach(pair => {
      const [lineData, text] = pair.split(':');
      if (!text) return;
      const commentText = text.trim();
      let targetIndices = [];

      if (lineData.includes('-')) {
        const [start, end] = lineData.split('-').map(n => parseInt(n.trim()));
        for (let i = start; i <= end; i++) targetIndices.push(i - 1);
      } else if (lineData.includes(',')) {
        targetIndices = lineData.split(',').map(n => parseInt(n.trim()) - 1);
      } else {
        const idx = parseInt(lineData.trim());
        if (!isNaN(idx)) targetIndices.push(idx - 1);
      }

      targetIndices.forEach(idx => {
        const targetLine = actualLines[idx];
        if (targetLine) {
          targetLine.setAttribute('data-tooltip', commentText);
          targetLine.classList.add('has-tooltip');
        }
      });
    });
  });
});