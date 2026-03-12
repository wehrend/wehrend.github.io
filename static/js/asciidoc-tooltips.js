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

  /**
   * REVISED: Finds the code block that immediately PRECEDES the comment
   */
  function findCodeBlock(commentNode) {
    // 1. Check siblings before the comment (most likely in Asciidoc/Hugo)
    let sibling = commentNode.parentElement;
    while (sibling) {
        // Look for common Hugo/Book code containers
        const code = sibling.querySelector('pre code, .highlight pre, td.code pre, .listingblock pre');
        if (code) return code;

        // Move to the previous element in the DOM
        sibling = sibling.previousElementSibling;
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
        const rawMap = JSON.parse(jsonStr);

        // Expand ranges like "1-5" into individual keys "1","2","3","4","5"
        const tooltipMap = {};
        Object.keys(rawMap).forEach(key => {
            if (key.includes('-')) {
                const [start, end] = key.split('-').map(Number);
                for (let i = start; i <= end; i++) {
                    tooltipMap[i.toString()] = rawMap[key];
                }
            } else {
                tooltipMap[key] = rawMap[key];
            }
        });

        const codeArea = findCodeBlock(node);

        if (codeArea && !codeArea.hasAttribute(CONFIG.processedAttr)) {
          console.log('✅ Found matching code block for tooltips');

          const lines = codeArea.innerHTML.split(/\r?\n/);
          const transformedHtml = lines.map((lineContent, index) => {
            const lineNum = (index + 1).toString();
            if (tooltipMap[lineNum]) {
              return `<span class="${CONFIG.triggerClass}" data-tip="${tooltipMap[lineNum]}">${lineContent || ' '}</span>`;
            }
            return lineContent;
          }).join('\n');

          codeArea.innerHTML = transformedHtml;
          codeArea.setAttribute(CONFIG.processedAttr, 'true');

          codeArea.querySelectorAll(`.${CONFIG.triggerClass}`).forEach(span => {
            createTooltip(span, span.getAttribute('data-tip'));
          });
        }
      } catch (e) {
        console.error('❌ Error processing tooltips:', e);
      }
    }
  }

  // Run logic
  if (document.readyState === 'complete') {
    processTooltips();
  } else {
    window.addEventListener('load', processTooltips);
  }

  // MutationObserver to catch dynamic loads
  const observer = new MutationObserver(() => processTooltips());
  observer.observe(document.body, { childList: true, subtree: true });

})();