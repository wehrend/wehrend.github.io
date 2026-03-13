(function () {
  'use strict';

  if (window.__proTooltipsInitialized) return;
  window.__proTooltipsInitialized = true;

  const CONFIG = {
    triggerClass: 'code-tip-trigger',
    processedAttr: 'data-tooltip-processed',
    dataClass: 'code-tooltip-data',
    tippyTheme: 'light-border'
  };

  /* -------------------------
     Detect device type
  --------------------------*/

  const isTouchDevice =
    window.detectIt &&
    (detectIt.primaryInput === 'touch' || detectIt.hasTouch);

  const tooltipTrigger = isTouchDevice ? 'click' : 'mouseenter focus';

  console.log(
    'Tooltip mode:',
    isTouchDevice ? 'Touch (tap)' : 'Desktop (hover)'
  );

  /* -------------------------
     Helper
  --------------------------*/

  function expandTooltipMap(rawMap) {
    const tooltipMap = {};

    Object.keys(rawMap).forEach(key => {
      if (key.includes('-')) {
        const [s, e] = key.split('-').map(Number);
        for (let i = s; i <= e; i++) tooltipMap[i] = rawMap[key];
      } else {
        tooltipMap[key] = rawMap[key];
      }
    });

    return tooltipMap;
  }

  function findCodeElement(node) {
    let el = node.parentElement;

    for (let i = 0; i < 6 && el; i++) {
      const code = el.querySelector('pre code, code');
      if (code) return code;
      el = el.previousElementSibling || el.parentElement;
    }

    return null;
  }

  function getLineElements(codeElement) {

    /* Hugo / highlight.js usually wraps lines in spans */

    const lines = Array.from(codeElement.children);

    if (lines.length > 1) return lines;

    /* fallback search */

    const spans = codeElement.querySelectorAll('span');

    if (spans.length > 1) return Array.from(spans);

    return [];
  }

  function bindTooltips(codeElement, tooltipMap) {

    const lines = getLineElements(codeElement);

    if (!lines.length) {
      console.warn('⚠️ No line wrappers detected.');
      return;
    }

    lines.forEach((lineEl, idx) => {

      const lineNum = idx + 1;

      if (!tooltipMap[lineNum]) return;

      lineEl.classList.add(CONFIG.triggerClass);
      lineEl.dataset.tip = tooltipMap[lineNum];

      if (typeof tippy !== 'undefined') {

        tippy(lineEl, {
          content: tooltipMap[lineNum],
          theme: CONFIG.tippyTheme,
          placement: 'right',
          interactive: true,
          trigger: tooltipTrigger,
          appendTo: () => document.body,
          hideOnClick: isTouchDevice
        });

      }

    });

  }

  function process() {

    const dataNodes = document.querySelectorAll(
      `.${CONFIG.dataClass}:not([${CONFIG.processedAttr}])`
    );

    dataNodes.forEach(node => {

      try {

        const raw = JSON.parse(node.textContent.trim());
        const tooltipMap = expandTooltipMap(raw);

        const codeElement = findCodeElement(node);

        if (!codeElement) return;

        bindTooltips(codeElement, tooltipMap);

        node.setAttribute(CONFIG.processedAttr, 'true');

      } catch (e) {

        console.error('Tooltip parsing error', e);

      }

    });

  }

  /* -------------------------
     Mutation observer (debounced)
  --------------------------*/

  let scheduled = false;

  function scheduleProcess() {
    if (scheduled) return;

    scheduled = true;

    requestAnimationFrame(() => {
      scheduled = false;
      process();
    });
  }

  process();

  document.addEventListener('DOMContentLoaded', scheduleProcess);
  window.addEventListener('load', scheduleProcess);

  new MutationObserver(scheduleProcess).observe(document.body, {
    childList: true,
    subtree: true
  });

})();