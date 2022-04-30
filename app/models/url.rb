# frozen_string_literal: true

class Url < ApplicationRecord
  PRESIST_RETRIES = 10
  UNIQUE_URL_LENGTH = 5

  has_many :clicks, dependent: :destroy

  validates :short_url, uniqueness: true
  validates :original_url, presence: true
  validates :original_url,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'Valid URL required' }

  around_create :generate_unique_url

  def current_month_daily_clicks
    clicks.from_this_month.group("DATE_TRUNC('day', created_at)").count.to_a.map do |arr|
      [arr.first.strftime('%e'), arr.second]
    end
  end

  def current_months_browser_counts
    clicks.from_this_month.group('browser').count.to_a
  end

  def current_months_platform
    clicks.from_this_month.group('platform').count.to_a
  end

  private

  private_constant :PRESIST_RETRIES, :UNIQUE_URL_LENGTH

  def unique_url_candidate
    charset = ('A'..'Z').to_a
    (0...UNIQUE_URL_LENGTH).map { charset[rand(charset.size)] }.join
  end

  def generate_unique_url(retries = PRESIST_RETRIES)
    loop do
      self.short_url = short_url || unique_url_candidate
      break unless self.class.unscoped.exists?(short_url: short_url)
    end

    yield
  rescue ActiveRecord::RecordNotUnique
    raise if retries <= 0

    retries -= 1
    retry
  end
end
