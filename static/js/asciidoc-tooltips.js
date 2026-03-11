(function() {
  'use strict';

  console.log('🔧 pro-tooltips.js: Starting robust initialization');

  const CONFIG = {
    triggerClass: 'code-tip-trigger',
    processedAttr: 'data-tooltip-processed',
    commentPrefix: 'code-tooltips:',
    tippyTheme: 'light-border'
  };

  function createTooltip(el, content) {
    if (typeof tippy === 'undefined') return;
    tippy(el, {
      content: content,
      theme: CONFIG.tippyTheme,
      placement: 'right',
      interactive: true,
      appendTo: () => document.body,
    });
  }

  function findCodeBlock(commentNode) {
    let parent = commentNode.parentElement;
    for (let i = 0; i < 10; i++) {
      if (!parent) break;
      // Target the actual code container
      const code = parent.querySelector('pre code, .highlight pre, td.code pre');
      if (code) return code;
      parent = parent.parentElement;
    }
    return null;
  }

  function processTooltips() {
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_COMMENT);
    let node;

    while (node = walker.nextNode()) {
      const text = node.nodeValue.trim();
      if (!text.startsWith(CONFIG.commentPrefix)) continue;

      try {
        const jsonStr = text.replace(CONFIG.commentPrefix, '').trim();
        const tooltipMap = JSON.parse(jsonStr);
        const codeArea = findCodeBlock(node);

        if (codeArea && !codeArea.hasAttribute(CONFIG.processedAttr)) {
          // Use a Regex split to handle different line ending styles
          const lines = codeArea.innerHTML.split(/\r?\n/);

          console.log(`📊 Processing ${lines.length} lines for block.`);

          const newHtml = lines.map((lineContent, index) => {
            const lineNum = (index + 1).toString();
            // Wrap the line. If it's an empty line, we still wrap it to keep the index correct.
            if (tooltipMap[lineNum]) {
              return `<span class="${CONFIG.triggerClass}" data-tip="${tooltipMap[lineNum]}">${lineContent || ' '}</span>`;
            }
            return lineContent;
          }).join('\n');

          codeArea.innerHTML = newHtml;
          codeArea.setAttribute(CONFIG.processedAttr, 'true');

          // Initialize Tippy on the newly created spans
          codeArea.querySelectorAll(`.${CONFIG.triggerClass}`).forEach(span => {
            createTooltip(span, span.getAttribute('data-tip'));
          });

          console.log('✅ Tooltips applied successfully.');
        }
      } catch (e) {
        console.error('❌ Error processing tooltips:', e);
      }
    }
  }

  // Final Safety: Run after a tiny delay to ensure Chroma/Prism finished highlighting
  window.addEventListener('load', () => {
    setTimeout(processTooltips, 100);
  });

  const observer = new MutationObserver(() => processTooltips());
  observer.observe(document.body, { childList: true, subtree: true });

})();