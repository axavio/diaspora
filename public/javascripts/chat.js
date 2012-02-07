function updateChatBadge(n) {
  var badge = $('#chat_badge .badge_count');
  badge.html(n);
  if( n == 0 ) {
    badge.hide();
  } else {
    badge.show();
  }
}

function showChatMessages() {
  $('#chat_dropdown').show();
  updateChatBadge(0);
  $.get('/chat_messages_mark_all_as_read');
}

$(document).ready( function() {
  $('#chat_badge').click( function() {
    var dd = $('#chat_dropdown');
    if( dd.css('display') == 'none' ) {
      showChatMessages();
    } else {
      dd.hide();
    }
    return false;
  } );

  $('#chat-text').keypress( function (e) {
    if( e.which == 13 ) {
      $(this).attr('disabled','disabled');
      $(this).addClass('disabled');
      $.post(
        '/chat_messages',
        {
          text: $(this).val(),
          partner: $('#chat-partner').val()
        },
        function(data) {
          if( ! data.success ) {
            if( data.error ) {
              alert(data.error);
            }
          } else {
            $('#chat-text').val('');
          }

          $('#chat-text').removeClass('disabled');
          $('#chat-text').removeAttr('disabled');
        }
      );
    }
  } );

  $('#people_stream.contacts .online .content, .chat_message .to').live( 'click', function() {
    showChatMessages();
    $('#chat-partner').val( $(this).data('diaspora_handle') );
    $('#chat-text').focus();
  } );

  $('.chat_message')
    .live( 'mouseenter', function() { $(this).find('.to').show(); } )
    .live( 'mouseleave', function() { $(this).find('.to').hide(); } )
  ;
} );
