module ApplicationHelper
  def to_money price
    ('%.2f' % price).gsub(/\B(?=(\d{3})+(?!\d))/, " ")
  end
end
