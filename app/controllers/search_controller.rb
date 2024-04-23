class SearchController < ApplicationController
  def search
    query = params[:query].downcase
    @search_results = Course.where('LOWER(title) LIKE ?', "%#{query}%")
      .or(Course.where('LOWER(description) LIKE ?', "%#{query}%"))
    render json: @search_results
  end
end
