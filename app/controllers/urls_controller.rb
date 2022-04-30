# frozen_string_literal: true

class UrlsController < ApplicationController
  after_action :track_click, only: :visit, if: -> { params[:short_url].present? }
  before_action :set_url, only: %w[show visit]

  def index
    # recent 10 short urls
    @url = Url.new
    @urls = Url.last(10)
  end

  def create
    Url.create!(permitted_params)
    redirect_to urls_path
  end

  def show
    @daily_clicks = @url.current_month_daily_clicks
    @browsers_clicks = @url.current_months_browser_counts
    @platform_clicks = @url.current_months_platform
  end

  def visit
    redirect_to @url.original_url
  end

  private

  def permitted_params
    params.require(:url).permit(:original_url)
  end

  def set_url
    @url = Url.find_by!(short_url: params[:url] || params[:short_url])
  end

  def track_click
    Click.create!(
      url: @url,
      browser: browser.name,
      platform: browser.platform.name
    )
  end
end
