#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora

  class Exporter
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
  end

  module Exporters
    module XML
      def execute(user)
        builder = Nokogiri::XML::Builder.new do |xml|
          user_person_id = user.person.id
          xml.export {
            
            xml.version {
              xml.parent << 'calispora-exporter 0.0.2'
            }
            
            xml.notes {
              xml.parent << '*** THIS IS A WORK IN PROGRESS!! *** '
              xml.parent << 'User profile included. '
              xml.parent << 'Aspects included. '
              xml.parent << 'Contacts included. '
              xml.parent << 'Export keys and profiles have been removed. '
              xml.parent << 'Posts authored by the user are included, without likes, comment or reshare count. '
              xml.parent << 'Comments authored by the user are included, but in stand-alone state. '
              xml.parent << 'Comments have parent_guid, but no created_at date. '
              xml.parent << 'Photos uploaded by the user have their name and location (uri) listed. '
            }

            xml.user {
              xml.username user.username
              xml.serialized_private_key user.serialized_private_key

              xml.parent << user.person.to_xml
            }



            xml.aspects {
              user.aspects.each do |aspect|
                xml.aspect {
                  xml.name aspect.name

#                  xml.person_ids {
                    #aspect.person_ids.each do |id|
                      #xml.person_id id
                    #end
                  #}

                  xml.post_ids {
                    aspect.posts.find_all_by_author_id(user_person_id).each do |post|
                      xml.post_id post.id
                    end
                  }
                }
              end
            }

            xml.contacts {
              user.contacts.each do |contact|
              xml.contact {
                xml.user_id contact.user_id
                xml.person_id contact.person_id
                xml.person_guid contact.person.guid
                xml.person_diaspora_handle contact.person.diaspora_handle

                xml.aspects {
                  contact.aspects.each do |aspect|
                    xml.aspect {
                      xml.name aspect.name
                    }
                  end
                }
              }
              end
            }

             xml.people {
              user.contacts.each do |contact|
                person = contact.person
                xml.parent << person.to_xml

              end
            }

           xml.posts {
              user.posts.find_all_by_author_id(user_person_id).each do |post|
                post.comments.each do |comment|
                  xml.parent << comment.to_xml
                end
                if ! post.instance_of?(Reshare)
                #if post.to_xml.to_s.index('<reshare>').nil?
                  xml.parent << post.to_xml
                end
              end
            }

            # DEBUG: comments have no created_at dumped to xml.  Why not?
            
            xml.comments {
              user.comments.find_all_by_author_id(user_person_id).each do |comment|
                #post.comments.each do |comment|
                #  post_doc << comment.to_xml
                #end
                xml.parent << comment.to_xml
              end
            }

            xml.photos {
              user.photos.find_all_by_author_id(user_person_id).each do |photo|
                #post.comments.each do |comment|
                #  post_doc << comment.to_xml
                #end
                xml.parent << photo.to_xml
              end
            }

          }
        end
        
        doc = Nokogiri::XML(builder.to_xml.to_s)

        # chop the fluff that isn't needed and/or doesn't belong to this user
        # This is a hack to extra data until we have better control
        # over the fields that are written to the XML
      
        # remove comments on my posts
        doc.xpath('/export/posts/comment').each do |node|
          node.remove
        end

        # remove posts I have reshared
        # this is redundant since we filtered reshares above
        #doc.xpath('/export/posts/reshare').each do |node|
        #  node.remove
        #end

        # remove author_signatures on comments
        doc.xpath('/export/comments/comment/author_signature').each do |node|
          node.remove
        end

        # remove parent_author_signatures on comments
        doc.xpath('/export/comments/comment/parent_author_signature').each do |node|
          node.remove
        end

        # remove exported_keys from people comments
        doc.xpath('/export/people/person/exported_key').each do |node|
          node.remove
        end

        # remove profiles from people except current user
        doc.xpath('/export/people/person/profile').each do |node|
          node.remove
        end

        # This is a hack.  Nokogiri interprets *.to_xml as a string.
        # we want to inject document objects, instead.  See lines: 25,35,40.
        # Solutions?
        CGI.unescapeHTML(doc.to_xml.to_s)
      end
    end
  end

end
