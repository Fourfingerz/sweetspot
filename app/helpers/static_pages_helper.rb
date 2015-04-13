module StaticPagesHelper

  def get_featured_photo story
    if !story.featured_photo.nil?
      url = attachment_url(Film.find(story.featured_photo), :image)
      return url
    end
  end
end
