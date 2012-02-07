function updateChatBadge(n) {
  var badge = $('#chat_badge .badge_count');
  badge.html(n);
  if( n == 0 ) {
    badge.hide();
  } else {
    badge.show();
  }
}

function markActiveConversationRead() {
  $.post(
    '/chat_messages_mark_conversation_read',
    { person_id: $('.partner.active').data('person_id') },
    function(response) {
      updateChatBadge( parseInt(response.num_unread) );
    }
  );
}

function showChatMessages() {
  $('#chat_dropdown').show();
  markActiveConversationRead();
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
          partner: $('.partner.active').data('person_id')
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
    /* TODO: Start new conversation with this person */
    /* $('#chat-partner').val( $(this).data('diaspora_handle') ); */
    $('#chat-text').focus();
  } );

  $('.chat_message')
    .live( 'mouseenter', function() { $(this).find('.to').show(); } )
    .live( 'mouseleave', function() { $(this).find('.to').hide(); } )
  ;

  $('.partner').live( 'click', function() {
    var person_id = $(this).data('person_id');
    $('#chat_dropdown .conversation').hide();
    $('.conversation[data-person_id="' + person_id + '"]').show();
    $('.partner').removeClass('active');
    $(this).addClass('active');
    markActiveConversationRead();
  } );
} );
