jQuery(function($){
  var el = $('.accounts.distribute');
  if (!el.length) return;
  el.empty();
  window.distributeAccount = new DistributeAccountView({ el: el });
});
