class PagesController < ApplicationController
  rescue_from Exception, with: :not_found

  def not_found
    render 'pages/not_found', status: 404
  end

  def vacancy
  end
end
