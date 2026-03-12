(function() {
  'use strict';

  if (window.__proTooltipsInitialized) return;
  window.__proTooltipsInitialized = true;

  console.log('🚀 [Tooltip-Debug] Script Start (Element Mode)');

  const CONFIG = {
    triggerClass: 'code-tip-trigger',
    processedAttr: 'data-tooltip-processed',
    dataClass: 'code-tooltip-data', // The new target class
    tippyTheme: 'light-border'
  };

  function findCodeBlock(dataNode) {
    let current = dataNode;
    // Walk backwards through siblings to find the code block
    while (current) {
      const code = current.querySelector('pre code, .highlight pre, td.code pre, .listingblock pre') ||
                   (current.tagName === 'PRE' ? current : null);
      if (code) return code;

      // If the current element doesn't have it, check the previous sibling
      let sibling = current.previousElementSibling;
      if (sibling) {
        const sibCode = sibling.querySelector('pre code, .highlight pre, td.code pre, .listingblock pre') ||
                        (sibling.tagName === 'PRE' ? sibling : null);
        if (sibCode) return sibCode;
      }
      current = current.parentElement;
      if (current && current.tagName === 'BODY') break;
    }
    return null;
  }

  function process() {
    const dataNodes = document.querySelectorAll(`.${CONFIG.dataClass}`);

    if (dataNodes.length === 0) {
      // Don't log this every time to avoid spamming the console
      return;
    }

    dataNodes.forEach((node, i) => {
      if (node.hasAttribute(CONFIG.processedAttr)) return;

      try {
        const rawMap = JSON.parse(node.textContent.trim());
        const codeArea = findCodeBlock(node);

        if (!codeArea) {
          console.error(`❌ [Debug] Found data block #${i+1} but no code block nearby!`);
          return;
        }

        console.log(`✅ [Debug] Processing data block #${i+1}`);

        // Expand ranges
        const tooltipMap = {};
        Object.keys(rawMap).forEach(key => {
          if (key.includes('-')) {
            const [start, end] = key.split('-').map(Number);
            for (let j = start; j <= end; j++) { tooltipMap[j.toString()] = rawMap[key]; }
          } else { tooltipMap[key] = rawMap[key]; }
        });

        const lines = codeArea.innerHTML.split(/\r?\n/);
        codeArea.innerHTML = lines.map((content, idx) => {
          const lineNum = (idx + 1).toString();
          return tooltipMap[lineNum]
            ? `<span class="${CONFIG.triggerClass}" data-tip="${tooltipMap[lineNum]}">${content || ' '}</span>`
            : content;
        }).join('\n');

        codeArea.setAttribute(CONFIG.processedAttr, 'true');
        node.setAttribute(CONFIG.processedAttr, 'true'); // Mark data as used

        codeArea.querySelectorAll('.' + CONFIG.triggerClass).forEach(span => {
          tippy(span, {
            content: span.getAttribute('data-tip'),
            theme: CONFIG.tippyTheme,
            placement: 'right',
            interactive: true,
            appendTo: () => document.body
          });
        });

      } catch (e) {
        console.error('❌ [Debug] JSON Error:', e, node.textContent);
      }
    });
  }

  window.addEventListener('load', process);
  new MutationObserver(process).observe(document.body, { childList: true, subtree: true });
})();