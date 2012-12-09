jQuery(function($){

  var bindBankEntriesSumit = function(){
    var context = $(this);
    context.find('form').submit(function(e){
      var form = $(this);
      $.ajax({
        url: form.attr('action'),
        data: form.serialize(),
        type: 'PUT',
        context: context,
        complete: function(xhr, status){
          context.html(xhr.responseText);
          bindBankEntriesSumit.call(context);
        }
      });
      return false;
    });
  };

  $('.bank-entries').on('click', 'a[data-action=edit]', function(e){
    e.preventDefault();
    var href = this.href,
        li = $(this).parent('li');
    li.load(href, bindBankEntriesSumit);
  });

  $('.bank-entries').on('click', 'form button[data-action=add]', function(e){
    e.preventDefault();
    var form = $(this).closest('form'),
        template = form.find('.template-account-entry').html();
    template = template.replace(/new_account_entry/g, (new Date).getTime())
    form.find('.account-entries').append(template);
  });

});
