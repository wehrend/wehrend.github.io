(function () {
  'use strict';

  if (window.__proTooltipsInitialized) return;
  window.__proTooltipsInitialized = true;

  const CONFIG = {
    triggerClass: 'code-tip-trigger',
    processedAttr: 'data-tooltip-processed',
    tooltipBoundAttr: 'data-tooltip-bound',
    dataClass: 'code-tooltip-data',
    tippyTheme: 'light-border'
  };

  const hasDetectIt = typeof window.detectIt !== 'undefined';
  const isTouchDevice = hasDetectIt &&
    (window.detectIt.primaryInput === 'touch' || window.detectIt.hasTouch);

  function expandTooltipMap(rawMap) {
    const tooltipMap = {};

    Object.keys(rawMap).forEach((key) => {
      if (key.includes('-')) {
        const [start, end] = key.split('-').map(Number);
        if (!Number.isNaN(start) && !Number.isNaN(end)) {
          for (let i = start; i <= end; i++) {
            tooltipMap[i] = rawMap[key];
          }
        }
      } else {
        const n = Number(key);
        if (!Number.isNaN(n)) {
          tooltipMap[n] = rawMap[key];
        }
      }
    });

    return tooltipMap;
  }

  function isCodeBlockElement(el) {
    if (!el || el.nodeType !== 1) return false;

    if (el.matches('pre')) {
      return !!el.querySelector('code');
    }

    if (el.matches('code')) {
      return true;
    }

    if (el.matches('.highlight, .chroma, .code-block, figure.highlight')) {
      return !!el.querySelector('pre code, code');
    }

    return false;
  }

  function extractCodeElement(blockEl) {
    if (!blockEl) return null;

    if (blockEl.matches('code')) return blockEl;
    if (blockEl.matches('pre')) return blockEl.querySelector('code');
    return blockEl.querySelector('pre code, code');
  }

  function findAssociatedCodeElement(dataNode) {
    let current = dataNode;

    while (current) {
      let sibling = current.previousElementSibling;

      while (sibling) {
        if (isCodeBlockElement(sibling)) {
          return extractCodeElement(sibling);
        }

        const nestedCode = sibling.querySelector?.('pre code, code');
        if (nestedCode) {
          return nestedCode;
        }

        sibling = sibling.previousElementSibling;
      }

      current = current.parentElement;
    }

    return null;
  }

  function getLineElements(codeElement) {
    if (!codeElement) return [];

    const directChildren = Array.from(codeElement.children).filter((el) => {
      return el.textContent !== '';
    });

    if (directChildren.length > 1) {
      return directChildren;
    }

    const pre = codeElement.closest('pre');
    if (pre) {
      const preDirectChildren = Array.from(pre.children).filter((el) => {
        if (el === codeElement) return false;
        return el.textContent !== '';
      });

      if (preDirectChildren.length > 1) {
        return preDirectChildren;
      }
    }

    const lineCandidates = Array.from(
      codeElement.querySelectorAll('span, div')
    ).filter((el) => {
      if (el.children.length > 0) return false;
      return el.textContent.trim() !== '';
    });

    if (lineCandidates.length > 1) {
      return lineCandidates;
    }

    return [];
  }

  function buildTippyOptions(content) {
    if (isTouchDevice) {
      return {
        content,
        theme: CONFIG.tippyTheme,
        placement: 'right',
        interactive: true,
        trigger: 'click',
        hideOnClick: true,
        appendTo: () => document.body
      };
    }

    return {
      content,
      theme: CONFIG.tippyTheme,
      placement: 'right',
      interactive: true,
      trigger: 'mouseenter focus',
      appendTo: () => document.body
    };
  }

  function bindTooltipsToCode(codeElement, tooltipMap) {
    const lines = getLineElements(codeElement);

    if (!lines.length) {
      console.warn('Tooltip script: no line wrapper elements found.', codeElement);
      return false;
    }

    lines.forEach((lineEl, idx) => {
      const lineNum = idx + 1;
      const tip = tooltipMap[lineNum];

      if (!tip) return;

      lineEl.classList.add(CONFIG.triggerClass);
      lineEl.setAttribute('data-tip', tip);

      if (lineEl.hasAttribute(CONFIG.tooltipBoundAttr)) return;
      lineEl.setAttribute(CONFIG.tooltipBoundAttr, 'true');

      if (typeof window.tippy !== 'undefined') {
        window.tippy(lineEl, buildTippyOptions(tip));
      }
    });

    return true;
  }

  function process() {
    const dataNodes = document.querySelectorAll(
      `.${CONFIG.dataClass}:not([${CONFIG.processedAttr}])`
    );

    dataNodes.forEach((node) => {
      try {
        const rawMap = JSON.parse(node.textContent.trim());
        const tooltipMap = expandTooltipMap(rawMap);
        const codeElement = findAssociatedCodeElement(node);

        if (!codeElement) {
          console.warn('Tooltip script: no associated code block found for tooltip data node.', node);
          return;
        }

        const success = bindTooltipsToCode(codeElement, tooltipMap);

        if (success) {
          node.setAttribute(CONFIG.processedAttr, 'true');
        }
      } catch (err) {
        console.error('Tooltip script: failed to parse tooltip JSON.', err, node);
      }
    });
  }

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