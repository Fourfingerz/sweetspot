# == Schema Information
#
# Table name: stories
#
#  id             :integer          not null, primary key
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  byline         :text
#  blurb          :text
#  featured_photo :string
#  first_slide    :string
#  deleted_at     :datetime
#
# Indexes
#
#  index_stories_on_deleted_at  (deleted_at)
#

require 'rails_helper'

RSpec.describe Story, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
