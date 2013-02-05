(function(){

  var T = function(){ T.init.apply(T, arguments); };
  T.version = '2.0 pre-release';
  T.init = function(collectionName, tests){
    var root = this;
    var options = Array.prototype.slice.call(arguments, 2);
    var extension;
    while(extension = options.pop()){
      tests = { '': tests };
      for (var name in extension){
        tests[name] = extension[name];
      }
    }
    root.Collection([collectionName], tests, [], []);
  };

  T.Collection = function(collectionName, tests, collectionBefore, collectionAfter, callback){
    var root = this;
    callback = callback || function(context){ root.reporter(context); };
    var context;
    var before = (collectionBefore || []).concat();
    var after  = (collectionAfter  || []).concat();
    var beforeAll  = tests['before all'] || function(){},
        afterAll   = tests['after all' ] || function(){};
    if (tests['before each']) { before.push(  tests['before each']); }
    if (tests['after each' ]) { after.unshift(tests['after each' ]); }
    delete(tests['before all' ]);
    delete(tests['before each']);
    delete(tests['after each' ]);
    delete(tests['after all'  ]);
    context = new root.Context(root, collectionName);
    try {
      beforeAll.call(context, context);
    } catch (e) {
      context.setException(e);
      context.name = collectionName.concat('before all');
      callback(context);
      afterAll && afterAll.call(context, context);
      return;
    }
    var noWait = function(){ return context.waitForCount === 0; },
        didWait = false;
    if (!noWait()){
      didWait = true;
      context.status = 'running';
      callback(context);
    }
    root.waitFor(noWait, function(){
      if (context.exception){
        context.name = collectionName.concat('before all');
        callback(context);
        afterAll && afterAll.call(context, context);
        return;
      }
      context.name = collectionName;
      var originalCallback = callback,
          runningChildren = {},
          observeChildren = function(context){
            if (context.status === 'running'){
              runningChildren[context.name] = true;
            } else if (context.status !== 'running'){
              delete runningChildren[context.name];
            }
            originalCallback.apply(null, arguments);
          };
      for(var testName in tests){
        var test = tests[testName];
        if (typeof(test) === 'function') {
          root.Runner(collectionName.concat(testName), before, test, after, observeChildren);
        } else {
          var newCollectionName = collectionName;
          if (testName !== '') {
            newCollectionName = newCollectionName.concat(testName);
          }
          root.Collection(newCollectionName, test, before, after, observeChildren);
        }
      }
      root.waitFor(function(){
        var noRunningChildren = true;
        for(var name in runningChildren){
          noRunningChildren = false;
          break;
        }
        return noRunningChildren;
      }, function(){
        try {
          afterAll.call(context, context);
        } catch (e) {
          context.setException(e);
          context.name = collectionName.concat('after all');
          callback(context);
        }
        if (!noWait()){
          didWait = true;
          context.status = 'running';
          context.name = collectionName;
          callback(context);
        }
        root.waitFor(noWait, function(){
          if (didWait) {
            context.status = 'done';
            context.name = collectionName;
            callback(context);
          }
        });
      });
    });
  };

// Runner
  T.Runner = function(testName, beforeCalls, test, afterCalls, callback){
    beforeCalls = beforeCalls.concat();
    afterCalls = afterCalls.concat();
    var root = this;
    var context = new root.Context(root, testName);
    var noWait = function(){ return context.waitForCount === 0; };
    var runBeforeCalls = function(){
      if (beforeCalls.length) {
        root.waitFor(noWait, function(){
          try {
            beforeCalls.shift().call(context, context);
          } catch (e) {
            context.setException(e);
          }
          runBeforeCalls();
        });
      }
    };
    runBeforeCalls();
    if (!noWait()){
      context.status = 'running';
      callback(context);
    }
    root.waitFor(function(time){ return noWait(time) && beforeCalls.length === 0; }, function(){
      if (!context.exception) {
        try {
          test.call(context, context);
        } catch (e) {
          context.setException(e);
        }
      }
      if (!noWait()){
        context.status = 'running';
        callback(context);
      }
      root.waitFor(noWait, function(){
        var runAfterCalls = function(){
          if (afterCalls.length) {
            root.waitFor(noWait, function(){
              try {
                afterCalls.shift().call(context, context);
              } catch (e) {
                context.setException(e);
              }
              runAfterCalls();
            });
          }
        };
        runAfterCalls();
        root.waitFor(function(time){ return noWait(time) && afterCalls.length === 0; }, function(){
          if (context.exception) {
            callback(context);
          } else {
            context.status = 'pass';
            callback(context);
          }
        });
      });
    });
  };

// Context
  T.Context = function(root, name){
    this.root = root;
    this.name = name;
    this.status = 'running';
    this.assertionCount = 0;
    this.waitForCount = 0;
  };
  T.Context.prototype.setException = function(exception){
    this.exception = exception;
    if (exception.constructor === this.root.Failure){
      this.status = 'fail';
    } else {
      this.status = 'error';
    }
  };
  T.Context.prototype.waitFor = function(condition, callback){
    var context = this;
    this.waitForCount += 1;
    context.root.waitFor(function(){ return condition.apply(context, arguments); }, function(){
      try {
        callback.call(context, context);
      } catch(e) {
        context.setException(e);
      }
      context.waitForCount -= 1;
    });
  };
  T.Context.prototype.assert = function(context, message){
    this.assertionCount++;
    if (!context) {
      if (message === undefined) { message = context+" is not true"; }
      throw new this.root.Failure(message);
    }
  };
  T.Context.prototype.assertEqual = function(expected, actual, message){
    this.assertionCount++;
    if (!this.root.isEqual(expected, actual)) {
      if (message === undefined) { message = "expected\n"+this.root.inspect(expected)+" but was\n"+this.root.inspect(actual); }
      throw new this.root.Failure(message);
    }
  };

// Failure
//TODO: make this an actual error so I get a stack.
  T.Failure = function(message){ this.message = message; };

// Helpers
  T.isEqual = function(expected, actual){
    return expected === actual || this.inspect(expected) === this.inspect(actual);
  };
  T.inspect = function(subject, stack){
    stack = stack || [];
    for(var i=0,e;e=stack[i];i++){
      if (e === subject) {
        return '<recursive>';
      }
    }
    switch(typeof(subject)){
    case 'undefined': return 'undefined';
    case 'string':    return '"'+subject+'"';
    case 'object':
      if (subject === null) {
        return 'null';
      } else if (subject.constructor === Array) {
        var output='[', first=true;
        var newStack = stack.concat();
        newStack.push(subject);
        for(var i=0,e;e=subject[i];i++){
          if (!first){ output += ','; }
          output += this.inspect(e, newStack);
          first = false;
        }
        return output+']';
      } else if (subject.nodeType === 1) {
        var output = ['<'+subject.tagName.toLowerCase()];
        if (subject.id){ output.push('id="'+subject.id+'"'); }
        if (subject.className){ output.push('class="'+subject.className+'"'); }
        return output.concat('/>').join(' ');
      }
      var output = '{', first=true;
      var newStack = stack.concat();
      newStack.push(subject);

      var properties = [];
      for(var property in subject) {
        properties.push(property);
      }
      properties.sort();

      for(var i=0,property;property=properties[i];i++){
        if (!first){ output += ','; }
        output += property+':'+this.inspect(subject[property], newStack);
        first = false;
      }
      return output+'}';
    }
    return subject.toString();
  };
  T.waitFor = function(condition, callback){
    var startTime = new Date();
    if (condition((new Date()) - startTime)){
      callback();
    } else {
      var interval = setInterval(function(){
        if (condition((new Date()) - startTime)){
          clearInterval(interval);
          callback();
        }
      }, 100);
    }
  };
  T.clone = function(parent, child){
    var root = this,
        type = typeof(parent);
    if (type === 'undefined') {
      parent = root;
      type = 'function';
      child = function(){ root.init.apply(child, arguments); };
    }
    if (child === undefined) {
      if (type === 'string' || type === 'number' || type === 'boolean') return parent;
      child = {};
      if (type === 'function'){
        child = function(){ return parent.apply(this, arguments); };
        var constructor = function(){ this.constructor = child; };
        constructor.prototype = parent.prototype;
        child.prototype = new constructor;
      }
    }
    if (type === 'function' || type === 'object'){
      for (var prop in parent){
        if (parent.hasOwnProperty(prop)){
          child[prop] = root.clone(parent[prop]);
        }
      }
    }
    return child;
  };

// Reporting
  T.reporter = function(context){
    typeof(window) === 'undefined' ? this.nodeReporter(context) : this.domReporter(context);
  };

// SimpleReporter
  T.SimpleReporter = T.clone(Function, function(){
    var counts       = { tests: 0, pass: 0, fail: 0, error: 0 },
        runningTests = {},
        timeout;
    return function reporter(context){
      var testName = context.name.join(': ');
      if (context.status === 'running'){
        runningTests[testName] = true;
      } else if (context.status !== 'running'){
        delete runningTests[testName];
      }

      if (context.status !== 'running' && context.status !== 'done'){
        reporter.contextFinished(context);
        counts.tests++;
        counts[context.status]++;
      }

      if (timeout){
        clearTimeout(timeout);
        delete timeout;
      }
      var anyRunningTests = false;
      for (var name in runningTests){
        return;
      }
      timeout = setTimeout(function(){
        delete timeout;
        reporter.testsFinished(counts);
      }, 400);
    };
  });
  T.SimpleReporter.prototype.contextFinished = function(context){
    throw 'implement this yourself';
  };
  T.SimpleReporter.prototype.testsFinished = function(counts){
    throw 'implement this yourself';
  };

// NodeReporter
  T.nodeReporter = (function(){
    var redColor     = '\033[31m',
        resetColor   = '\033[39m',
        puts, exit;
    var reporter = new T.SimpleReporter();
    reporter.contextFinished = function(context){
      var prefix = '', suffix = '';
      if (context.status !== 'pass'){ prefix = redColor; suffix = resetColor; }
      var output = context.name.join(': ')+': '+context.status
      if (context.status !== 'pass' && context.exception && context.exception.message) {
        output += ': '+context.exception.message;
      }
      output += ' ('+context.assertionCount+' assertion'+(context.assertionCount === 1 ? '' : 's')+' run)';
      puts = puts || require('sys').puts;
      puts(prefix + output + suffix);
    };
    reporter.testsFinished = function(counts){
      var output, prefix = '', suffix = '', details = [];
      if (counts.error > 0){
        prefix = redColor;
        suffix = resetColor;
        output = 'Error!';
      } else if (counts.fail > 0){
        prefix = redColor;
        suffix = resetColor;
        output = 'Fail.';
      } else {
        output = 'Pass.';
      }
      output += ' ('+counts.tests+' tests: ';
      if (counts.pass > 0){ details.push(counts.pass+' passed'); }
      if (counts.fail > 0){ details.push(counts.fail+' failed'); }
      if (counts.error > 0){ details.push(counts.error+' errored'); }
      puts = puts || require('sys').puts;
      puts(prefix + output + details.join(', ')+')' + suffix);
      exit = exit || process.exit;
      exit((counts.fail || counts.error) ? 1 : 0)
    };
    return reporter;
  })();

// DomReporter
  T.domReporter = (function(){
    var runningTests = {},
        counts = { tests: 0, running: 0, pass: 0, fail: 0, error: 0 },
        log, summary;
    var reporter = function(context){
      var testName = context.name.join(': '),
          root = this;
      root.domReporter.showPassing = root.domReporter.showPassing || false;
      if (!log){
        log = root.domReporter.createLog.call(root);
        summary = root.domReporter.createSummary.call(root);
        log.appendChild(summary);
      }
      counts.tests++;
      counts[context.status]++;

      var testLog = runningTests[testName];
      if (testLog) {
        counts.tests--;
        counts.running--;
      } else {
        testLog = document.createElement('li');
        log.appendChild(testLog);
        if (context.status !== 'running'){
          delete runningTests[testName];
        }
      }
      if (context.status === 'done'){
        counts.tests--;
        log.removeChild(testLog);
      } else {
        root.domReporter.updateResult.call(root, context, testLog);
        if (context.status === 'running'){
          runningTests[testName] = testLog;
        }
      }

      root.domReporter.updateSummary(counts, summary);
    };
    reporter.createLog = function(){
      var log = document.createElement('ul');
      log.id = 'test-it-results';
      this.waitFor(function(){ return document.body; }, function(){
        document.body.appendChild(log);
      });
      return log;
    };
    reporter.createSummary = function() {
      var root = this,
          summary = document.createElement('li');
      summary.onclick = function(){
        root.domReporter.showPassing = !root.domReporter.showPassing;
        log.className = root.domReporter.showPassing ? 'show-passing' : '';
      };
      return summary;
    };
    reporter.updateResult = function(context, li){
      li.className = context.status;
      var html = context.name.join(': ') + ': ' + context.status;
      html += ' ('+context.assertionCount+' assertion'+(context.assertionCount === 1 ? '' : 's')+' run)';
      li.innerHTML = html.replace(/</g, '&lt;').replace(/>/g, '&gt;');
      if (context.exception && context.exception.message){
        var pre = document.createElement('pre');
        pre.innerHTML = context.exception.message.replace(/</g, '&lt;').replace(/>/g, '&gt;');
        li.appendChild(pre);
      }
    };
    reporter.updateSummary = function(counts, summary){
      var html;
      if (counts.running){
        html = 'Running... ';
        summary.className = 'summary running';
      } else if (counts.error){
        html = 'Error! ';
        summary.className = 'summary error';
      } else if (counts.fail){
        html = 'Fail. ';
        summary.className = 'summary fail';
      } else {
        html = 'Pass. ';
        summary.className = 'summary pass';
      }
      html += '<small>('+counts.tests+' test'+(counts.tests === 1 ? '' : 's')+': ';
      var details = [];
      if (counts.pass) { details.push(counts.pass+' passed'); }
      if (counts.running) { details.push(counts.running+' running'); }
      if (counts.fail) { details.push(counts.fail+' failed'); }
      if (counts.error) { details.push(counts.error+' errored'); }
      html += details.join(', ');
      summary.innerHTML = html+')</small>';
    }
    return reporter;
  })();

  if (typeof module !== 'undefined') module.exports = T;
  if (typeof window !== 'undefined') window.TestIt = T;
})();
