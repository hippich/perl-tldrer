$(function(){

  var url = window.location.pathname, 
  urlRegExp = new RegExp("^https?\:\/\/[^\/]+" + url.replace(/\/$/,'') + "$"); // create regexp to match current url pathname and remove trailing slash if present as it could collide with the link in navigation in case trailing slash wasn't present there

  // if this is home page - match only / hrefs
  if (url == '/') {
    urlRegExp = new RegExp("^https?\:\/\/[^\/]+$");
  }

  // now grab every link from the navigation
  $('.nav a').each(function(){
    // and test its normalized href against the url pathname regexp
    if(urlRegExp.test(this.href.replace(/\/$/,''))){
        $(this).addClass('active');
    }
  });

  // Add Suggest Title button
  $(".add-post #url").each(function() {
    var el = $(this);
    var title_el = $(this).parents('form').eq(0).find('#title');
    el.after('<a href="#" id="suggest-title" class="btn btn-info">Suggest a Title</a>');
    $("#suggest-title").click(function() {
      var button = $(this);

      if (button.hasClass('disabled')) { return; }

      if (el.val() == '') {
        alert("Please enter URL first.");
        return;
      }

      button.text('Loading...').addClass('disabled');

      $.ajax({
        url: '/ajax/gettitle',
        type: 'POST',
        data: $('.add-post form').serialize(),
        success: function(data) {
          button.removeClass('disabled').text('Suggest a Title');
          if (data.status == 'success') {
            title_el.val( data.title );
          }
          else {
            alert("Unable to fetch URL.");
          }
        },
        error: function() {
          button.removeClass('disabled').text('Suggest a Title');
        },
      });
      return false;
    });
  });

});
