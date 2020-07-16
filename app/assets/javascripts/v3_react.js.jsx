/* globals React ReactDOM jQuery confirm */
/* eslint no-unused-vars: ["error", { "varsIgnorePattern": "^(App|Users|Ledgers)$" }] */
//= require jquery
//= require serviceworker-companion
//= require_self
//= require rrule/lib/rrule
//= require ./v3/react/admin
//= require ./v3/react/new

var API = (function(){
  var requests = [];
  var resolves = {};
  var requestTimeout;

  function doAPI(){
    jQuery.post({ url: '/api', context: resolves }, JSON.stringify(requests))
      .then(function(data){
        data.responses.forEach(function(response){
          this[response.reference]({ response: response, records: data.records });
        }, this);
      });
    requests = [];
    resolves = {};
  }

  return function API(request){
    request.reference = request.reference || Math.random().toString();
    requests.push(request);
    if (requestTimeout) clearTimeout(requestTimeout);
    requestTimeout = setTimeout(doAPI, 100);
    return new Promise(function(resolve){
      resolves[request.reference] = resolve;
    });
  };
})();

var app = document.querySelector('.admin');
if (app) ReactDOM.render(<AdminApp />, app);
