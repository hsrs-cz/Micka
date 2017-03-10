var Happy,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Happy = (function() {
  function Happy() {
    this.checkCheckboxState = bind(this.checkCheckboxState, this);
    this.checkCheckboxStateOnChange = bind(this.checkCheckboxStateOnChange, this);
    this.checkCheckboxStateOnClick = bind(this.checkCheckboxStateOnClick, this);
    this.radioOnChange = bind(this.radioOnChange, this);
    this.colors = ['primary', 'success', 'info', 'warning', 'danger', 'white', 'gray'];
    this.templates = {
      radio: '<div class="happy-radio"><b></b></div>',
      checkbox: '<div class="happy-checkbox"> <svg viewBox="0 0 30 30"> <rect class="mark-storke" x="15" y="3" rx="1" ry="1" width="10" height="4"/> <rect class="mark-storke" x="-7" y="21" rx="1" ry="1" width="19" height="4"/> </svg> </div>',
      text: '',
      textarea: ''
    };
  }

  Happy.prototype.colorify = function(input, happy_input, class_string) {
    if (input.classList.contains(class_string)) {
      happy_input.classList.add(class_string);
    }
    if (input.classList.contains(class_string + '-border')) {
      return happy_input.classList.add(class_string + '-border');
    }
  };

  Happy.prototype.thicknessify = function(input, happy_input) {
    if (input.classList.contains('thin')) {
      return happy_input.classList.add('thin');
    }
  };

  Happy.prototype.setNames = function(input, happy_input) {
    var value;
    happy_input.setAttribute('data-name', input.getAttribute('name'));
    value = input.getAttribute('value');
    if (typeof (value !== 'undefined') && value !== false && value !== null) {
      return happy_input.setAttribute('data-value', input.getAttribute('value'));
    }
  };

  Happy.prototype.init = function() {
    this.initRadio();
    return this.initCheckbox();
  };

  Happy.prototype.removeBySelector = function(s) {
    var el, elements, i, len, results;
    elements = document.querySelectorAll(s);
    results = [];
    for (i = 0, len = elements.length; i < len; i++) {
      el = elements[i];
      results.push(el.parentNode.removeChild(el));
    }
    return results;
  };

  Happy.prototype.reset = function() {
    this.removeBySelector('.happy-radio');
    this.removeBySelector('.happy-checkbox');
    return this.init();
  };

  Happy.prototype.initRadio = function() {
    var c, happy_input, i, input, inputs, j, len, len1, ref, results;
    inputs = document.querySelectorAll('input[type=radio].happy');
    results = [];
    for (i = 0, len = inputs.length; i < len; i++) {
      input = inputs[i];
      input.insertAdjacentHTML('afterend', this.templates.radio);
      happy_input = input.nextElementSibling;
      ref = this.colors;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        c = ref[j];
        this.colorify(input, happy_input, c);
        this.setNames(input, happy_input);
      }
      this.thicknessify(input, happy_input);
      this.checkRadioState(input);
      results.push(document.addEventListener('change', this.radioOnChange));
    }
    return results;
  };

  Happy.prototype.radioOnChange = function(e) {
    var happy_radio, happy_radios, i, len, name, selector, target_input;
    target_input = e.target;
    if (!target_input.classList.contains('happy')) {
      return;
    }
    name = target_input.getAttribute('name');
    selector = '.happy-radio[data-name="' + name + '"]';
    happy_radios = document.querySelectorAll(selector);
    for (i = 0, len = happy_radios.length; i < len; i++) {
      happy_radio = happy_radios[i];
      happy_radio.classList.remove('active');
    }
    return this.checkRadioState(target_input);
  };

  Happy.prototype.checkRadioState = function(input) {
    var happy_radio, name, selector, value;
    if (input.checked) {
      name = input.getAttribute('name');
      value = input.getAttribute('value');
      selector = '.happy-radio[data-name="' + name + '"][data-value="' + value + '"]';
      happy_radio = document.querySelector(selector);
      if (happy_radio) {
        return happy_radio.classList.add('active');
      }
    }
  };

  Happy.prototype.initCheckbox = function() {
    var c, happy_input, i, input, inputs, j, len, len1, ref, results;
    inputs = document.querySelectorAll('input[type=checkbox].happy');
    results = [];
    for (i = 0, len = inputs.length; i < len; i++) {
      input = inputs[i];
      input.insertAdjacentHTML('afterend', this.templates.checkbox);
      happy_input = input.nextElementSibling;
      ref = this.colors;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        c = ref[j];
        this.colorify(input, happy_input, c);
        this.setNames(input, happy_input);
      }
      this.thicknessify(input, happy_input);
      this.checkCheckboxState(input);
      document.addEventListener('click', this.checkCheckboxStateOnClick);
      results.push(document.addEventListener('change', this.checkCheckboxStateOnChange));
    }
    return results;
  };

  Happy.prototype.checkCheckboxStateOnClick = function(e) {
    var event, happy_input, ie, input, selector;
    if (e.target.tagName === 'svg') {
      happy_input = e.target.parentNode;
    } else if (e.target.tagName === 'rect') {
      happy_input = e.target.parentNode.parentNode;
    } else {
      happy_input = e.target;
    }
    if (!happy_input || !happy_input.classList.contains('happy-checkbox')) {
      return;
    }
    e.preventDefault();
    selector = 'input[type=checkbox][name="' + happy_input.getAttribute('data-name') + '"]';
    input = document.querySelector(selector);
    if (input) {
      if (happy_input.classList.contains('active')) {
        input.checked = false;
        happy_input.classList.remove('active');
      } else {
        input.checked = true;
        happy_input.classList.add('active');
      }
      ie = window.navigator.userAgent.indexOf("MSIE ");
      if (ie) {
        event = document.createEvent('Event');
        event.initEvent('change', true, true);
      } else {
        event = new Event('change', {
          'bubbles': true
        });
      }
      return input.dispatchEvent(event);
    }
  };

  Happy.prototype.checkCheckboxStateOnChange = function(e) {
    var input;
    if (e.target.classList.contains('happy')) {
      input = e.target;
      return this.checkCheckboxState(input);
    }
  };

  Happy.prototype.checkCheckboxState = function(input) {
    var element, selector;
    selector = '.happy-checkbox[data-name="' + input.getAttribute('name') + '"]';
    element = document.querySelector(selector);
    if (element) {
      if (input.checked) {
        return element.classList.add('active');
      } else {
        return element.classList.remove('active');
      }
    }
  };

  return Happy;

})();

document.addEventListener('DOMContentLoaded', function() {
  window.happy = new Happy();
  return window.happy.init();
});
