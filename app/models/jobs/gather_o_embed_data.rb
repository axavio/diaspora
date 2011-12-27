#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

module Jobs
  class GatherOEmbedData < Base
    @queue = :http_service

    def self.perform(post_id, url)
      post = Post.find_by_id(post_id)
      if post
        post.o_embed_cache = OEmbedCache.find_or_create_by_url(url)
        post.save
      end
    end
  end
end
