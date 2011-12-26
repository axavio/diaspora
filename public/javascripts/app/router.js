app.Router = Backbone.Router.extend({
  routes: {
    "stream": "stream",
    "comment_stream": "stream",
    "like_stream": "stream",
    "mentions": "stream",
    "people/:id": "stream",
      "u/:name": "stream",
    "tag_followings": "stream",
    "tags/:name": "stream",
    "posts/:id": "stream"
  },

  stream: function() {
    app.stream = new app.views.Stream().render();
    $("#main_stream").html(app.stream.el);
  }
});
