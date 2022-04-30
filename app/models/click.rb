# frozen_string_literal: true

class Click < ApplicationRecord
  belongs_to :url

  validates :browser, :platform, presence: true

  after_create_commit :increment_click_count

  scope :from_this_month, -> { where(created_at: Time.current.beginning_of_month..(Time.current.end_of_month)) }

  private

  def increment_click_count
    url.update(clicks_count: url.clicks_count + 1)
  end
end
