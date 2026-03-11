/**
 * pro-tooltips.js
 * Version: 2.0 (Range Support + Span-Wrap)
 * Optimized for Hugo Book / Goldmark
 */
(function() {
  'use strict';

  const CONFIG = {
    triggerClass: 'code-tip-trigger',
    processedAttr: 'data-tooltip-processed',
    commentPrefix: 'code-tooltips:',
    tippyTheme: 'light-border'
  };

  /**
   * Helper to initialize Tippy.js
   */
  function createTooltip(el, content) {
    if (typeof tippy === 'undefined') return;
    tippy(el, {
      content: content,
      theme: CONFIG.tippyTheme,
      placement: 'right',
      arrow: true,
      animation: 'shift-away',
      interactive: true,
      appendTo: () => document.body,
    });
  }

  /**
   * Locates the actual <code> or <pre> block near the HTML comment
   */
  function findCodeBlock(commentNode) {
    let current = commentNode.parentElement;
    for (let i = 0; i < 10; i++) {
      if (!current) break;
      // Targets Hugo's common code structures (Highlight, Listing blocks, or Tables)
      const code = current.querySelector('pre code, .highlight pre, td.code pre, pre');
      if (code && !code.hasAttribute(CONFIG.processedAttr)) return code;
      current = current.parentElement;
    }
    return null;
  }

  /**
   * Main logic: Parses comments and wraps lines in <span> tags
   */
  function processTooltips() {
    const walker = document.createTreeWalker(
      document.body,
      NodeFilter.SHOW_COMMENT,
      null,
      false
    );

    let node;
    while (node = walker.nextNode()) {
      const text = node.nodeValue.trim();
      if (!text.startsWith(CONFIG.commentPrefix)) continue;

      try {
        const jsonStr = text.replace(CONFIG.commentPrefix, '').trim();
        const tooltipMap = JSON.parse(jsonStr);
        const codeArea = findCodeBlock(node);

        if (codeArea) {
          // Splitting by line breaks while preserving existing HTML tags
          const lines = codeArea.innerHTML.split(/\r?\n/);

          const transformedHtml = lines.map((lineContent, index) => {
            const lineNum = index + 1;
            let explanation = null;

            // Range Logic: Check if lineNum falls within a "1-5" style key
            for (const [key, value] of Object.entries(tooltipMap)) {
              if (key.includes('-')) {
                const [start, end] = key.split('-').map(Number);
                if (lineNum >= start && lineNum <= end) explanation = value;
              } else if (parseInt(key) === lineNum) {
                explanation = value;
              }
            }

            if (explanation) {
              return `<span class="${CONFIG.triggerClass}" data-tip="${explanation}">${lineContent || ' '}</span>`;
            }
            return lineContent;
          }).join('\n');

          codeArea.innerHTML = transformedHtml;
          codeArea.setAttribute(CONFIG.processedAttr, 'true');

          // Initialize Tippy on the new spans
          codeArea.querySelectorAll(`.${CONFIG.triggerClass}`).forEach(span => {
            createTooltip(span, span.getAttribute('data-tip'));
          });
        }
      } catch (e) {
        // Silently skip if JSON is malformed or comment is unrelated
      }
    }
  }

  // --- Execution ---

  // Run on initial load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', processTooltips);
  } else {
    processTooltips();
  }

  // Run on window load to catch late-rendering blocks
  window.addEventListener('load', () => {
    setTimeout(processTooltips, 100);
  });

  // Observe DOM changes (useful for single-page-app style navigation in Hugo Book)
  const observer = new MutationObserver(() => processTooltips());
  observer.observe(document.body, { childList: true, subtree: true });

})();